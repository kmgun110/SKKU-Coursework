#include <stdio.h>
#include "support.h"
#include <cublas_v2.h>

//  nvcc -o matmul main.cu kernel.cu utils.cu -lcuda -lcublas

int main(int argc, char* argv[]) {
    Timer timer;

    if (argc != 4) {
        printf("Usage: %s <A_rows> <A_cols/B_rows> <B_cols>\n", argv[0]);
        return 1;
    }

    int A_row = atoi(argv[1]);
    int A_col = atoi(argv[2]);
    int B_row = atoi(argv[2]);
    int B_col = atoi(argv[3]);
    int C_row = A_row;
    int C_col = B_col;

    // host mem allocation
    size_t A_size = (size_t)A_row * A_col * sizeof(float);
    size_t B_size = (size_t)B_row * B_col * sizeof(float);
    size_t C_size = (size_t)C_row * C_col * sizeof(float);

    float* pA = (float*)malloc(A_size);
    float* pB = (float*)malloc(B_size);

    float* pC_gpu_result = (float*)malloc(C_size);
    float* pC_gpu_result1 = (float*)malloc(C_size);
    float* pC_gpu_result2 = (float*)malloc(C_size);
    float* pC_gpu_result3 = (float*)malloc(C_size);
    float* pC_gpu_result4 = (float*)malloc(C_size);
    float* pC_gpu_result5 = (float*)malloc(C_size);

    // Initialize host data
    genData(pA, A_row * A_col);
    genData(pB, B_row * B_col);

    //device mem allocation
    float* pAdev = NULL;
    float* pBdev = NULL;
    float* pCdev = NULL;

    cudaMalloc((void**)&pAdev, A_size);
    cudaMalloc((void**)&pBdev, B_size);
    cudaMalloc((void**)&pCdev, C_size);

    cudaMemset(pCdev, 0, C_size);
    cudaMemcpy(pAdev, pA, A_size, cudaMemcpyHostToDevice);
    cudaMemcpy(pBdev, pB, B_size, cudaMemcpyHostToDevice);

    //////// 01. host side compute ////////
    // startTime(&timer);
    // for (unsigned i=0; i<100; i++){
    //      matmul_cpu(pC_cpu_result, pA, pB, C_row, C_col, A_col);
    // }
    // stopTime(&timer);
    // printf("[01] cpu : %f s\n", elapsedTime(timer)/100.0f);
    //////////////////////////////////////

    ///// Warmup /////
    cublasHandle_t cublas_handle_warmup;
    cublasCreate(&cublas_handle_warmup);
    
    cudaMemset(pCdev, 0, C_size);
    float alpha = 1.0f;
    float beta = 0.0f;

    cudaDeviceSynchronize();
    startTime(&timer);
    for (int i = 0; i < 50; ++i) {

        cublasGemmEx(
            cublas_handle_warmup,
            CUBLAS_OP_N, CUBLAS_OP_N,           // A, B transpose 안 함
            C_col, C_row, A_col,                // N, M, K
            &alpha,
            pBdev, CUDA_R_32F, C_col,           // B: (K×N), leading dim = N
            pAdev, CUDA_R_32F, A_col,           // A: (M×K), leading dim = K
            &beta,
            pCdev, CUDA_R_32F, C_col,           // C: (M×N), leading dim = N
            CUBLAS_COMPUTE_32F,                 // float32 precision
            CUBLAS_GEMM_DEFAULT_TENSOR_OP       // Tensor Core 사용 가능 (가능한 경우)
        );
    }
    cudaDeviceSynchronize();
    cublasDestroy(cublas_handle_warmup);
    /////////////////

    ///// 02.  cuBLAS compute ///////////
    cublasHandle_t cublas_handle;
    cublasCreate(&cublas_handle);
    
    cudaMemset(pCdev, 0, C_size);

    cudaDeviceSynchronize();
    startTime(&timer);
    for (int i = 0; i < 100; ++i) {

        cublasGemmEx(
            cublas_handle,
            CUBLAS_OP_N, CUBLAS_OP_N,           // A, B transpose 안 함
            C_col, C_row, A_col,                // N, M, K
            &alpha,
            pBdev, CUDA_R_32F, C_col,           // B: (K×N), leading dim = N
            pAdev, CUDA_R_32F, A_col,           // A: (M×K), leading dim = K
            &beta,
            pCdev, CUDA_R_32F, C_col,           // C: (M×N), leading dim = N
            CUBLAS_COMPUTE_32F,                 // float32 precision
            CUBLAS_GEMM_DEFAULT_TENSOR_OP       // Tensor Core 사용 가능 (가능한 경우)
        );
    }
    cudaDeviceSynchronize();
    stopTime(&timer);
    printf("[02] cublas : %f ms\n", elapsedTime(timer) * 10);
    cudaMemcpy(pC_gpu_result, pCdev, C_size, cudaMemcpyDeviceToHost);
 
    cublasDestroy(cublas_handle);
    //////////////////////////////////////
    
    dim3 dimGrid((C_row + TILE_WIDTH - 1)/TILE_WIDTH, (C_col + TILE_WIDTH - 1)/TILE_WIDTH, 1);
    dim3 dimBlock(TILE_WIDTH, TILE_WIDTH, 1);

    /// 03. naive implementation /////
    cudaDeviceSynchronize();
    startTime(&timer);

    for (unsigned i=0; i<100; i++){
        naive_matmul<<<dimGrid, dimBlock>>> (C_row, C_col, A_col, pAdev, pBdev, pCdev);
    }
    cudaDeviceSynchronize();
    stopTime(&timer);
    printf("[03] naive gpu : %f s\n", elapsedTime(timer)/100.0f);
    cudaMemcpy(pC_gpu_result1, pCdev, C_size, cudaMemcpyDeviceToHost);
    compareResults(pC_gpu_result, pC_gpu_result1, C_row * C_col);
    /////////////////////////////////
    
    ///// 04. Shared Memory Blocking /////
    cudaMemset(pCdev, 0, C_size);
    cudaDeviceSynchronize();
    startTime(&timer);
    for (unsigned i=0; i<100; i++){
        matmul_shared<<<dimGrid, dimBlock>>> (pCdev, pAdev, pBdev, C_row, C_col, A_col);
    }
    cudaDeviceSynchronize();
    stopTime(&timer);
    printf("[04] shared gpu : %f ms\n", elapsedTime(timer) * 10);
    cudaMemcpy(pC_gpu_result1, pCdev, C_size, cudaMemcpyDeviceToHost);
    compareResults(pC_gpu_result, pC_gpu_result1, C_row * C_col);
    /////////////////////////////
    
    ///// 05. 1d block tiling /////
    cudaMemset(pCdev, 0, C_size);
    dim3 dimGrid_1d(((C_col+BN_1d-1)/ BN_1d), (C_row + BM_1d - 1) / BM_1d);
    dim3 dimBlock_1d((BM_1d * BN_1d) / TM);
    cudaDeviceSynchronize();
    startTime(&timer);
    for (unsigned i=0; i<100; i++){
        matmul_1D_blocktile_<<<dimGrid_1d, dimBlock_1d>>>(pCdev, pAdev, pBdev, C_row, C_col, A_col);
    }
    cudaDeviceSynchronize();
    stopTime(&timer);
    printf("[05] 1D_blocktile : %f ms\n", elapsedTime(timer)*10);
    cudaMemcpy(pC_gpu_result2, pCdev, C_size, cudaMemcpyDeviceToHost);
    compareResults(pC_gpu_result, pC_gpu_result2, C_row * C_col);

    ///////////////////////////////

    ///// 06. 2d block tiling /////
    cudaMemset(pCdev, 0, C_size);
    dim3 dimGrid_2d(((C_col+BN-1)/ BN), (C_row + BM - 1) / BM);
    dim3 dimBlock_2d((BN*BM)/(TM*TN), 1);
    cudaDeviceSynchronize();
    startTime(&timer);
    for (unsigned i=0; i<100; i++){
        matmul_2D_blocktile<<<dimGrid_2d, dimBlock_2d>>>(pCdev, pAdev, pBdev, C_row, C_col, A_col);
    }
    cudaDeviceSynchronize();
    stopTime(&timer);
    printf("[06] 2D_blocktile : %f ms\n", elapsedTime(timer) * 10);
    cudaMemcpy(pC_gpu_result3, pCdev, C_size, cudaMemcpyDeviceToHost);
    compareResults(pC_gpu_result, pC_gpu_result3, C_row * C_col);

    ///////////////////////////////

    ///// 07. 2d block tiling A transposed /////
    cudaMemset(pCdev, 0, C_size);

    cudaDeviceSynchronize();
    startTime(&timer);
    for (unsigned i=0; i<100; i++){
        matmul_2D_blocktile_at<<<dimGrid_2d, dimBlock_2d>>>(pCdev, pAdev, pBdev, C_row, C_col, A_col);
    }
    cudaDeviceSynchronize();
    stopTime(&timer);
    printf("[07] 2D_blocktile transposed : %f ms\n", elapsedTime(timer)* 10);
    cudaMemcpy(pC_gpu_result4, pCdev, C_size, cudaMemcpyDeviceToHost);
    compareResults(pC_gpu_result, pC_gpu_result4, C_row * C_col);
    ///////////////////////////////////////////
    
    ///// 08. Warp tiling /////
    cudaMemset(pCdev, 0, C_size);
    dim3 dimBlock_warp(NUM_THREADS);
    dim3 dimGrid_warp(((C_col+w_BN-1)/ w_BN), (C_row + w_BM - 1) / w_BM);
    cudaDeviceSynchronize();
    startTime(&timer);
    for (unsigned i=0; i<100; i++){
        matmul_warptile<<<dimGrid_warp, dimBlock_warp>>>(pCdev, pAdev, pBdev, C_row, C_col, A_col);
    }
    cudaDeviceSynchronize();
    stopTime(&timer);
    printf("[08] warp tiling : %f ms\n", elapsedTime(timer)* 10);
    cudaMemcpy(pC_gpu_result5, pCdev, C_size, cudaMemcpyDeviceToHost);
    compareResults(pC_gpu_result, pC_gpu_result5, C_row * C_col);
    ///////////////////////////////////////////

    /*
    ///// 04. 
    dim3 dimGrid_((C_row + TILE_WIDTH-1)/TILE_WIDTH, (C_col + TILE_WIDTH-1)/TILE_WIDTH, 1);
    cudaDeviceSynchronize();
    startTime(&timer);
    for (unsigned i=0; i<100; i++){ 
        sgemm_naive<<<dimGrid_, dimBlock>>>(C_row, C_col, A_col, pAdev, pBdev, pCdev);
    }
    cudaDeviceSynchronize();
    stopTime(&timer);
    printf("[04] article naive : %f s\n", elapsedTime(timer)/100.0f);
    cudaMemcpy(pC_gpu_result, pCdev, C_size, cudaMemcpyDeviceToHost);
    compareResults(pC_cpu_result, pC_gpu_result, C_row * C_col);
    //////////////////////////////////

    ////// 05. coalsced
    cudaDeviceSynchronize();
    startTime(&timer);
    for (unsigned i=0; i<100; i++){
        sgemm_naive_col<<<dimGrid_, dimBlock>>>(C_row, C_col, A_col, pAdev, pBdev, pCdev);
    }
    cudaDeviceSynchronize();
    stopTime(&timer);
    printf("[05] article coalsced : %f s\n", elapsedTime(timer)/100.0f);
    cudaMemcpy(pC_gpu_result, pCdev, C_size, cudaMemcpyDeviceToHost);
    compareResults(pC_cpu_result, pC_gpu_result, C_row * C_col);
    */
    /////////////////////////
    free(pA); free(pB); free(pC_gpu_result); 
    free(pC_gpu_result1); free(pC_gpu_result2); free(pC_gpu_result3); free(pC_gpu_result4); free(pC_gpu_result5);
    cudaFree(pAdev); cudaFree(pBdev); cudaFree(pCdev);
    printf("\nExecution finished.\n");
    return 0;
}