//kernel.16


#include <cuda_runtime.h>
#include <cuda_fp16.h>
#include "support.h"

using scalar_t = __half;  // FP16 스칼라 타입

// C(MxN) = A(MxK) * B(KxN)
#ifndef TILE
#define TILE 32
#endif

// ---------------- sgemm_tiled (half gmem, float compute) ----------------

__global__ void sgemm_tiled32_kernel(scalar_t* __restrict__ C,
                                     const scalar_t* __restrict__ A,
                                     const scalar_t* __restrict__ B,
                                     int M, int N, int K)
{
    __shared__ float As[TILE][TILE + 1]; // +1: bank conflict 회피
    __shared__ float Bs[TILE][TILE + 1];

    int row = blockIdx.y * TILE + threadIdx.y; // 0..M-1
    int col = blockIdx.x * TILE + threadIdx.x; // 0..N-1

    float acc = 0.0f;

    // K 방향 타일링
    for (int k0 = 0; k0 < K; k0 += TILE) {
        int a_col = k0 + threadIdx.x;
        if (row < M && a_col < K) {
            As[threadIdx.y][threadIdx.x] =
                __half2float(A[row * K + a_col]);
        } else {
            As[threadIdx.y][threadIdx.x] = 0.0f;
        }

        int b_row = k0 + threadIdx.y;
        if (b_row < K && col < N) {
            Bs[threadIdx.y][threadIdx.x] =
                __half2float(B[b_row * N + col]);
        } else {
            Bs[threadIdx.y][threadIdx.x] = 0.0f;
        }

        __syncthreads();

        #pragma unroll
        for (int kk = 0; kk < TILE; ++kk) {
            acc += As[threadIdx.y][kk] * Bs[kk][threadIdx.x];
        }

        __syncthreads();
    }

    if (row < M && col < N) {
        C[row * N + col] = __float2half(acc);
    }
}

extern "C" void sgemm_tiled(scalar_t* C, const scalar_t* A, const scalar_t* B,
                            int M, int N, int K)
{
    dim3 block(TILE, TILE);
    dim3 grid((N + TILE - 1) / TILE, (M + TILE - 1) / TILE);
    sgemm_tiled32_kernel<<<grid, block>>>(C, A, B, M, N, K);
}

// ---------------- 1D block tiling (half gmem, float compute) ----------------

__global__ void blocktiling_1d_kernel(scalar_t* __restrict__ C,
                                      const scalar_t* __restrict__ A,
                                      const scalar_t* __restrict__ B,
                                      int M, int N, int K)
{
    constexpr int PAD_BN = (4 - (BN_1d % 4)) % 4;
    constexpr int PAD_BM = (4 - (BM_1d % 4)) % 4;

    __shared__ float As1d[BK][BM_1d + PAD_BM];
    __shared__ float Bs1d[BK][BN_1d + PAD_BN];

    int blockRow = blockIdx.y;
    int blockCol = blockIdx.x;

    int tid = threadIdx.x;

    int colsPerThreadGroup = BN_1d / TM;  // 예: 64 / 8 = 8

    // local coordinate
    int localRow  = tid / colsPerThreadGroup;        // 0..BM_1d-1 (일반적으로 0..63)
    int localCol0 = (tid % colsPerThreadGroup) * TM; // 0,8,16,...56

    int row = blockRow * BM_1d + localRow;
    int col0 = blockCol * BN_1d + localCol0;

    float regC[TM];
    #pragma unroll
    for (int i = 0; i < TM; ++i) regC[i] = 0.0f;

    for (int bk = 0; bk < K; bk += BK)
    {
        // ----- load A tile (half -> float) -----
        for (int idx = tid; idx < ((BM_1d * BK) / 4); idx += blockDim.x) {
            int r = idx / (BK / 4);        // 0..BM_1d-1
            int c = (idx % (BK / 4));      // 0..(BK/4 - 1)
            int gRow = blockRow * BM_1d + r;
            int gCol = bk + c * 4;

            float v0 = 0.0f, v1 = 0.0f, v2 = 0.0f, v3 = 0.0f;
            if (gRow < M) {
                if (gCol + 0 < K) v0 = __half2float(A[gRow * K + gCol + 0]);
                if (gCol + 1 < K) v1 = __half2float(A[gRow * K + gCol + 1]);
                if (gCol + 2 < K) v2 = __half2float(A[gRow * K + gCol + 2]);
                if (gCol + 3 < K) v3 = __half2float(A[gRow * K + gCol + 3]);
            }

            int baseK = c * 4;
            if (baseK + 0 < BK) As1d[baseK + 0][r] = v0;
            if (baseK + 1 < BK) As1d[baseK + 1][r] = v1;
            if (baseK + 2 < BK) As1d[baseK + 2][r] = v2;
            if (baseK + 3 < BK) As1d[baseK + 3][r] = v3;
        }

        // ----- load B tile (half -> float) -----
        for (int idx = tid; idx < ((BK * BN_1d) / 4); idx += blockDim.x) {
            int r = idx / (BN_1d / 4);      // 0..BK-1
            int c = (idx % (BN_1d / 4)) * 4; // 0..BN_1d-1 step 4
            int gRow = bk + r;
            int gCol = blockCol * BN_1d + c;

            float v0 = 0.0f, v1 = 0.0f, v2 = 0.0f, v3 = 0.0f;
            if (gRow < K) {
                if (gCol + 0 < N) v0 = __half2float(B[gRow * N + gCol + 0]);
                if (gCol + 1 < N) v1 = __half2float(B[gRow * N + gCol + 1]);
                if (gCol + 2 < N) v2 = __half2float(B[gRow * N + gCol + 2]);
                if (gCol + 3 < N) v3 = __half2float(B[gRow * N + gCol + 3]);
            }

            if (c + 0 < BN_1d + PAD_BN) Bs1d[r][c + 0] = v0;
            if (c + 1 < BN_1d + PAD_BN) Bs1d[r][c + 1] = v1;
            if (c + 2 < BN_1d + PAD_BN) Bs1d[r][c + 2] = v2;
            if (c + 3 < BN_1d + PAD_BN) Bs1d[r][c + 3] = v3;
        }

        __syncthreads();

        // ----- compute -----
        if (row < M)
        {
            for (int kInner = 0; kInner < BK; ++kInner)
            {
                float aVal = As1d[kInner][localRow];

                // 한 스레드가 TM개의 열을 담당 (열 방향 레지스터 blocking)
                for (int t = 0; t < TM; ++t)
                {
                    int cLocal = localCol0 + t;
                    if (cLocal < BN_1d + PAD_BN) {
                        float bVal = Bs1d[kInner][cLocal];
                        regC[t] += aVal * bVal;
                    }
                }
            }
        }
        __syncthreads();
    }

    // ----- store C (float -> half) -----
    if (row < M)
    {
        for (int t = 0; t < TM; ++t)
        {
            int c = col0 + t;
            if (c < N) {
                C[row * N + c] = __float2half(regC[t]);
            }
        }
    }
}

extern "C" void blocktiling_1d(scalar_t* C, const scalar_t* A, const scalar_t* B,
                               int M, int N, int K)
{
    dim3 grid((N + BN_1d - 1) / BN_1d,
              (M + BM_1d - 1) / BM_1d);
    int threads = (BM_1d * BN_1d) / TM;
    blocktiling_1d_kernel<<<grid, threads>>>(C, A, B, M, N, K);
}

// ---------------- 2D block tiling (half gmem, float compute) ----------------

__global__ void blocktiling_2d_kernel(
    scalar_t* __restrict__ C,           // MxN
    const scalar_t* __restrict__ A,     // MxK
    const scalar_t* __restrict__ B,     // KxN
    int M, int N, int K)
{
    constexpr int PAD_BN = (4 - (BN_2d % 4)) % 4;
    constexpr int PAD_BM = (4 - (BM_2d % 4)) % 4;

    __shared__ float As2d[BK][BM_2d + PAD_BM];
    __shared__ float Bs2d[BK][BN_2d + PAD_BN];

    int blockRow = blockIdx.y;
    int blockCol = blockIdx.x;

    int tid = threadIdx.x;

    const int colsPerThreadGroup = BN_2d / TN;

    int threadRow = tid / colsPerThreadGroup;
    int threadCol = tid % colsPerThreadGroup;

    int rowBase = blockRow * BM_2d + threadRow * TM;
    int colBase = blockCol * BN_2d + threadCol * TN;

    float regC[TM * TN];
    #pragma unroll
    for (int i = 0; i < TM * TN; ++i) regC[i] = 0.0f;

    for (int bk = 0; bk < K; bk += BK)
    {
        // ----- load A tile (half -> float) -----
        for (int idx = tid; idx < ((BM_2d * BK) / 4); idx += blockDim.x) {
            int r = idx / (BK / 4);         // 0..BM_2d-1
            int c = (idx % (BK / 4));       // 0..(BK/4 - 1)
            int gRow = blockRow * BM_2d + r;
            int gCol = bk + c * 4;

            float v0 = 0.0f, v1 = 0.0f, v2 = 0.0f, v3 = 0.0f;
            if (gRow < M) {
                if (gCol + 0 < K) v0 = __half2float(A[gRow * K + gCol + 0]);
                if (gCol + 1 < K) v1 = __half2float(A[gRow * K + gCol + 1]);
                if (gCol + 2 < K) v2 = __half2float(A[gRow * K + gCol + 2]);
                if (gCol + 3 < K) v3 = __half2float(A[gRow * K + gCol + 3]);
            }

            int baseK = c * 4;
            if (baseK + 0 < BK) As2d[baseK + 0][r] = v0;
            if (baseK + 1 < BK) As2d[baseK + 1][r] = v1;
            if (baseK + 2 < BK) As2d[baseK + 2][r] = v2;
            if (baseK + 3 < BK) As2d[baseK + 3][r] = v3;
        }

        // ----- load B tile (half -> float) -----
        for (int idx = tid; idx < BK * (BN_2d / 4); idx += blockDim.x) {
            int r = idx / (BN_2d / 4);      // 0..BK-1
            int c = (idx % (BN_2d / 4)) * 4;
            int gRow = bk + r;
            int gCol = blockCol * BN_2d + c;

            float v0 = 0.0f, v1 = 0.0f, v2 = 0.0f, v3 = 0.0f;
            if (gRow < K) {
                if (gCol + 0 < N) v0 = __half2float(B[gRow * N + gCol + 0]);
                if (gCol + 1 < N) v1 = __half2float(B[gRow * N + gCol + 1]);
                if (gCol + 2 < N) v2 = __half2float(B[gRow * N + gCol + 2]);
                if (gCol + 3 < N) v3 = __half2float(B[gRow * N + gCol + 3]);
            }

            if (c + 0 < BN_2d + PAD_BN) Bs2d[r][c + 0] = v0;
            if (c + 1 < BN_2d + PAD_BN) Bs2d[r][c + 1] = v1;
            if (c + 2 < BN_2d + PAD_BN) Bs2d[r][c + 2] = v2;
            if (c + 3 < BN_2d + PAD_BN) Bs2d[r][c + 3] = v3;
        }

        __syncthreads();

        // ----- compute -----
        #pragma unroll
        for (int kInner = 0; kInner < BK; ++kInner) {
            float aReg[TM];

            #pragma unroll
            for (int i = 0; i < TM; ++i) {
                int r = threadRow * TM + i;
                aReg[i] = As2d[kInner][r];
            }

            #pragma unroll
            for (int j = 0; j < TN; j += 4) {
                int cLocal = threadCol * TN + j;

                float b0 = 0.0f, b1 = 0.0f, b2 = 0.0f, b3 = 0.0f;
                if (cLocal + 0 < BN_2d + PAD_BN) b0 = Bs2d[kInner][cLocal + 0];
                if (cLocal + 1 < BN_2d + PAD_BN) b1 = Bs2d[kInner][cLocal + 1];
                if (cLocal + 2 < BN_2d + PAD_BN) b2 = Bs2d[kInner][cLocal + 2];
                if (cLocal + 3 < BN_2d + PAD_BN) b3 = Bs2d[kInner][cLocal + 3];

                #pragma unroll
                for (int i = 0; i < TM; ++i) {
                    regC[i * TN + j + 0] += aReg[i] * b0;
                    regC[i * TN + j + 1] += aReg[i] * b1;
                    regC[i * TN + j + 2] += aReg[i] * b2;
                    regC[i * TN + j + 3] += aReg[i] * b3;
                }
            }
        }
        __syncthreads();
    }

    // ----- store C (float -> half) -----
    #pragma unroll
    for (int i = 0; i < TM; ++i) {
        int r = rowBase + i;
        if (r >= M) break;

        #pragma unroll
        for (int j = 0; j < TN; j += 4) {
            int c = colBase + j;

            if (c + 0 < N)
                C[r * N + c + 0] = __float2half(regC[i * TN + j + 0]);
            if (c + 1 < N)
                C[r * N + c + 1] = __float2half(regC[i * TN + j + 1]);
            if (c + 2 < N)
                C[r * N + c + 2] = __float2half(regC[i * TN + j + 2]);
            if (c + 3 < N)
                C[r * N + c + 3] = __float2half(regC[i * TN + j + 3]);
        }
    }
}

extern "C" void blocktiling_2d(
    scalar_t* C, const scalar_t* A, const scalar_t* B,
    int M, int N, int K)
{
    // BN_1d/BM_1d 대신 BN_2d/BM_2d를 써야 하는지 support.h 보고 맞춰도 됨.
    dim3 grid((N + BN_2d - 1) / BN_2d,
              (M + BM_2d - 1) / BM_2d);
    int threads = (BM_2d / TM) * (BN_2d / TN);
    blocktiling_2d_kernel<<<grid, threads>>>(C, A, B, M, N, K);
}
