// main.16

#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <cublas_v2.h>
#include <cuda_runtime.h>
#include <cuda_fp16.h>
#include "support.h"

// ./scripts/build_nvcc.sh
// ./build/attn_proj B T h dk

using scalar_t = __half;  // 스칼라 타입을 half로 사용

// --------------------- init (half) ---------------------
__global__ void fill_lin_half(scalar_t* a, int n, float seed){
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {
        // float로 계산한 뒤 half로 캐스팅
        float v = fmodf(0.001f * i + seed, 1.0f) - 0.5f; // [-0.5, 0.5)
        a[i] = __float2half(v);
    }
}

static inline void init_device_array_half(scalar_t* dptr, size_t n, float seed){
    int threads = 256;
    int blocks  = (int)((n + threads - 1) / threads);
    fill_lin_half<<<blocks, threads>>>(dptr, (int)n, seed);
}

// ---------------- row-major GEMM (cuBLAS, FP16 I/O + FP32 compute) ----------------
static inline void gemm_rowmajor_cublas_fp16(cublasHandle_t h,
                                             int M, int N, int K,
                                             const scalar_t* A, int lda,  // lda = K
                                             const scalar_t* B, int ldb,  // ldb = N
                                             scalar_t* C, int ldc) {      // ldc = N
    float alpha = 1.0f;
    float beta  = 0.0f;

    // row-major을 맞추기 위해 이전 float 코드와 동일하게 (C^T) = (B^T)*(A^T) 형태
    cublasStatus_t st = cublasGemmEx(
        h,
        CUBLAS_OP_N, CUBLAS_OP_N,
        N, M, K,
        &alpha,
        B, CUDA_R_16F, ldb,   // B^T: N x K
        A, CUDA_R_16F, lda,   // A^T: K x M
        &beta,
        C, CUDA_R_16F, ldc,   // C^T: N x M
        CUBLAS_COMPUTE_32F,   // 내부 연산은 FP32 accumulate
        CUBLAS_GEMM_DEFAULT_TENSOR_OP  // TensorCore 사용 옵션
    );
    if (st != CUBLAS_STATUS_SUCCESS){
        fprintf(stderr, "cublasGemmEx(fp16) failed (%d)\n", (int)st);
        std::exit(2);
    }
}

// -------------------- custom kernel (half 버전) --------------------
// NOTE: kernel 구현 파일(kernel.cu 등)에서도 시그니처와 내부 타입을 __half 기준으로 맞춰야 함.
extern "C" void sgemm_tiled(scalar_t* C, const scalar_t* A, const scalar_t* B,
                            int M, int N, int K);

extern "C" void blocktiling_1d(scalar_t* C, const scalar_t* A, const scalar_t* B,
                               int M, int N, int K);

extern "C" void blocktiling_2d(scalar_t* C, const scalar_t* A, const scalar_t* B,
                               int M, int N, int K);

// -------------------- host diff helper (float 기준) --------------------
static double max_abs_diff_host(const float* hA, const float* hB, size_t n){
    double md = 0.0;
    for (size_t i = 0; i < n; i++){
        double d = std::fabs((double)hA[i] - (double)hB[i]);
        if (d > md) md = d;
    }
    return md;
}

// ----------------------------- main -----------------------------
int main(int argc, char** argv){
    if (argc != 5){
        printf("Usage: %s <B> <T> <h> <dk>\n", argv[0]);
        return 1;
    }
    int B  = std::atoi(argv[1]);
    int T  = std::atoi(argv[2]);
    int h  = std::atoi(argv[3]);
    int dk = std::atoi(argv[4]);

    int d_model = h * dk;
    int M = B * T;      // rows of X_concat
    int K = d_model;    // cols of X_concat = rows of W
    int N = d_model;    // cols of W

    size_t nX = (size_t)M * K;
    size_t nW = (size_t)K * N;
    size_t nY = (size_t)M * N;

    scalar_t *dX=nullptr, *dW=nullptr;
    scalar_t *dY_ref=nullptr, *dY_sgemm=nullptr, *dY_1d=nullptr, *dY_2d=nullptr;

    CUDA_CHECK(cudaMalloc(&dX,      nX * sizeof(scalar_t)));
    CUDA_CHECK(cudaMalloc(&dW,      nW * sizeof(scalar_t)));
    CUDA_CHECK(cudaMalloc(&dY_ref,  nY * sizeof(scalar_t)));
    CUDA_CHECK(cudaMalloc(&dY_sgemm,nY * sizeof(scalar_t)));
    CUDA_CHECK(cudaMalloc(&dY_1d,   nY * sizeof(scalar_t)));
    CUDA_CHECK(cudaMalloc(&dY_2d,   nY * sizeof(scalar_t)));

    init_device_array_half(dX, nX, 0.123f);
    init_device_array_half(dW, nW, 0.456f);

    // cuBLAS
    cublasHandle_t handle;
    cublasCreate(&handle);
    cublasSetMathMode(handle, CUBLAS_TENSOR_OP_MATH);  // TensorCore 사용

    // ---------- cuBLAS baseline (fp16 I/O, fp32 compute) ----------
    gemm_rowmajor_cublas_fp16(handle, M, N, K, dX, K, dW, N, dY_ref, N);
    CUDA_CHECK(cudaDeviceSynchronize());

    const int iters = 20;
    Timer t1; startTime(t1);
    for (int i = 0; i < iters; i++){
        gemm_rowmajor_cublas_fp16(handle, M, N, K, dX, K, dW, N, dY_ref, N);
    }
    CUDA_CHECK(cudaDeviceSynchronize());
    float ms_cublas = stopTime(t1) / iters;
    double gflops_cublas = (2.0 * (double)M * (double)N * (double)K) / (ms_cublas * 1e6);

    // ---------- sgemm_tiled (half 버전) ----------
    sgemm_tiled(dY_sgemm, dX, dW, M, N, K);
    CUDA_CHECK(cudaDeviceSynchronize());

    Timer t2; startTime(t2);
    for (int i = 0; i < iters; i++){
        sgemm_tiled(dY_sgemm, dX, dW, M, N, K);
    }
    CUDA_CHECK(cudaDeviceSynchronize());
    float ms_sgemm = stopTime(t2) / iters;
    double gflops_sgemm = (2.0 * (double)M * (double)N * (double)K) / (ms_sgemm * 1e6);

    // ---------- 1D block tiling (half 버전) ----------
    blocktiling_1d(dY_1d, dX, dW, M, N, K);
    CUDA_CHECK(cudaDeviceSynchronize());

    Timer t3; startTime(t3);
    for (int i = 0; i < iters; i++){
        blocktiling_1d(dY_1d, dX, dW, M, N, K);
    }
    CUDA_CHECK(cudaDeviceSynchronize());
    float ms_1d = stopTime(t3) / iters;
    double gflops_1d = (2.0 * (double)M * (double)N * (double)K) / (ms_1d * 1e6);

    // ---------- 2D block tiling (half 버전) ----------
    blocktiling_2d(dY_2d, dX, dW, M, N, K);
    CUDA_CHECK(cudaDeviceSynchronize());

    Timer t4; startTime(t4);
    for (int i = 0; i < iters; i++){
        blocktiling_2d(dY_2d, dX, dW, M, N, K);
    }
    CUDA_CHECK(cudaDeviceSynchronize());
    float ms_2d = stopTime(t4) / iters;
    double gflops_2d = (2.0 * (double)M * (double)N * (double)K) / (ms_2d * 1e6);

    // ---------- accuracy (half -> float 변환 후 비교) ----------
    scalar_t *h_ref   = (scalar_t*)std::malloc(nY * sizeof(scalar_t));
    scalar_t *h_sgemm = (scalar_t*)std::malloc(nY * sizeof(scalar_t));
    scalar_t *h_1d    = (scalar_t*)std::malloc(nY * sizeof(scalar_t));
    scalar_t *h_2d    = (scalar_t*)std::malloc(nY * sizeof(scalar_t));

    CUDA_CHECK(cudaMemcpy(h_ref,   dY_ref,   nY * sizeof(scalar_t), cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaMemcpy(h_sgemm, dY_sgemm, nY * sizeof(scalar_t), cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaMemcpy(h_1d,    dY_1d,    nY * sizeof(scalar_t), cudaMemcpyDeviceToHost));
    CUDA_CHECK(cudaMemcpy(h_2d,    dY_2d,    nY * sizeof(scalar_t), cudaMemcpyDeviceToHost));

    float *ref_f   = (float*)std::malloc(nY * sizeof(float));
    float *sgemm_f = (float*)std::malloc(nY * sizeof(float));
    float *d1_f    = (float*)std::malloc(nY * sizeof(float));
    float *d2_f    = (float*)std::malloc(nY * sizeof(float));

    for (size_t i = 0; i < nY; ++i){
        ref_f[i]   = __half2float(h_ref[i]);
        sgemm_f[i] = __half2float(h_sgemm[i]);
        d1_f[i]    = __half2float(h_1d[i]);
        d2_f[i]    = __half2float(h_2d[i]);
    }

    double diff_sgemm = max_abs_diff_host(ref_f, sgemm_f, nY);
    double diff_1d    = max_abs_diff_host(ref_f, d1_f, nY);
    double diff_2d    = max_abs_diff_host(ref_f, d2_f, nY);

    printf("[cublas]   %dx%dx%d  %.3f ms  %.1f GFLOPs\n",
           M, N, K, ms_cublas, gflops_cublas);
    //printf("[sgemm]         %dx%dx%d  %.3f ms  %.1f GFLOPs  accuracy: %.3e\n",
           //M, N, K, ms_sgemm, gflops_sgemm, diff_sgemm);
    //printf("[1d blocktiling]    %dx%dx%d  %.3f ms  %.1f GFLOPs  accuracy: %.3e\n",
           //M, N, K, ms_1d, gflops_1d, diff_1d);
    printf("[2d blocktiling]    %dx%dx%d  %.3f ms  %.1f GFLOPs  accuracy: %.3e\n",
           M, N, K, ms_2d, gflops_2d, diff_2d);

    std::free(h_ref);   std::free(h_sgemm);
    std::free(h_1d);    std::free(h_2d);
    std::free(ref_f);   std::free(sgemm_f);
    std::free(d1_f);    std::free(d2_f);

    cublasDestroy(handle);
    cudaFree(dX); cudaFree(dW);
    cudaFree(dY_ref); cudaFree(dY_sgemm);
    cudaFree(dY_1d);  cudaFree(dY_2d);

    return 0;
}
