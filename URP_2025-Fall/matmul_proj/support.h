// 해당 header 파일 한번만 compile 되도록 보장
#ifndef __FILEH__
#define __FILEH__

#define TILE_WIDTH 32
#define BM_1d 64
#define BN_1d 64
#define BM 128
#define BN 128
#define BK 8
#define TM 8
#define TN 8

// parameters for warptiling
#define NUM_THREADS 128
#define w_BN 128
#define w_BM 128
#define w_BK 16
#define WN 64
#define WM 64
#define WNITER 4
#define w_TN 4
#define w_TM 8


#include <sys/time.h>
#include <assert.h>
typedef struct {
    struct timeval startTime;
    struct timeval endTime;
} Timer;

void startTime(Timer* timer);
void stopTime(Timer* timer);
float elapsedTime(Timer timer);


void matmul_cpu(float* C, const float* A, const float* B, int M, int N, int K);
void genData(float* ptr, unsigned int size);

bool compareResults(const float* ref, const float* test, int size, float tol = 1e-3);

__global__ void matmul_naive(float* g_C, const float* g_A, const float* g_B, const int M, const int N, const int K);
__global__ void sgemm_naive(int M, int N, int K, const float* A, const float* B, float* C);
__global__ void sgemm_naive_col(int M, int N, int K, const float* A, const float* B, float* C);
__global__ void matmul_shared(float* g_C, const float* g_A, const float* g_B, const int M, const int N, const int K);
__global__ void matmul_1D_blocktile(float* g_C, const float* g_A, const float* g_B, const int M, const int N, const int K);
__global__ void matmul_1D_blocktile_(float* g_C, const float* g_A, const float* g_B, const int M, const int N, const int K);
__global__ void matmul_2D_blocktile(float* g_C, const float* g_A, const float* g_B, const int M, const int N, const int K);
__global__ void matmul_2D_blocktile_at(float* g_C, const float* g_A, const float* g_B, const int M, const int N, const int K) ;
__global__ void matmul_warptile(float* g_C, const float* g_A, const float* g_B, const int M, const int N, const int K);


__global__ void sgemm1DBlocktiling(float* C, const float* A, const float* B, const int M, const int N, const int K);
__global__ void sgemm2DBlocktiling(float* C, const float* A, const float* B, const int M, const int N, const int K) ;

 __global__ void naive_matmul(int M, int N, int K, 
                             const float* __restrict__ A,
                             const float* __restrict__ B,
                             float* __restrict__ C);

__global__ void matmul_tiled_s(const float* __restrict__ A,
    const float* __restrict__ B,
    float* __restrict__ C,
    int M, int N, int K);                             

namespace warptile{
  template <const int rowStrideA, const int rowStrideB>
  __device__ void loadFromGmem(const int N, const int K, const float *g_A, const float *g_B, float *tileA, float *tileB, int threadRowA, int threadColA, int threadRowB, int threadColB){
    for (uint offset = 0; offset + rowStrideA <= w_BM; offset += rowStrideA){
      const float4 tmp = reinterpret_cast<const float4 *>(&g_A[(threadRowA + offset)*K + threadColA * 4])[0];
      tileA[(threadColA*4 + 0)* w_BM + threadRowA + offset] = tmp.x;
      tileA[(threadColA*4 + 1)* w_BM + threadRowA + offset] = tmp.y;
      tileA[(threadColA*4 + 2)* w_BM + threadRowA + offset] = tmp.z;
      tileA[(threadColA*4 + 3)* w_BM + threadRowA + offset] = tmp.w;
    }

    for (uint offset = 0; offset + rowStrideB <= w_BK; offset += rowStrideB){
      reinterpret_cast<float4 *>(&tileB[(threadRowB + offset)* w_BN + threadColB*4])[0] = reinterpret_cast<const float4 *>(&g_B[(threadRowB + offset)*N + threadColB*4])[0];
    }
  }

  template <const int WMITER, const int WSUBM, const int WSUBN>
  __device__ void processFromSmem(float *regM, float *regN, float *threadResults, const float *tileA, const float *tileB, const uint warpRow, const uint warpCol, const uint threadRowInWarp, const uint threadColInWarp){
    for (uint dotIdx =0; dotIdx < w_BK; ++dotIdx) {
      // populate registers for whole warptile
      // 여기 이해가 안됨......
      for (uint wSubRowIdx =0; wSubRowIdx < WMITER; ++wSubRowIdx){
        for (uint i =0; i< w_TM; ++i){
          regM[wSubRowIdx *w_TM + i] = tileA[(dotIdx * w_BM) + warpRow*WM + wSubRowIdx * WSUBM + threadRowInWarp * w_TM + i];
        }
      }
      for (uint wSubColIdx=0; wSubColIdx < WNITER; ++wSubColIdx){
        for (uint i=0; i< w_TN; ++i){
          regN[wSubColIdx * w_TN + i] = tileB[(dotIdx * w_BN) + warpCol * WN + wSubColIdx * WSUBN + threadColInWarp*w_TN + i];
        }
      }

      // execute warptile matmul (exploiting ILP)
      for (uint wSubRowIdx=0; wSubRowIdx<WMITER; ++wSubRowIdx){
        for (uint wSubColIdx=0; wSubColIdx<WNITER; ++wSubColIdx){
          // calculate per-thread results
          for (uint resIdxM=0; resIdxM < w_TM; ++resIdxM){
            for (uint resIdxN=0; resIdxN < w_TN; ++resIdxN){
              threadResults[(wSubRowIdx * w_TM + resIdxM)*(WNITER*w_TN)+(wSubColIdx * w_TN)+resIdxN] += regM[wSubRowIdx*w_TM + resIdxM]*regN[wSubColIdx*w_TN+resIdxN];
            }
          }
        }
      }
    }
  }
} // namespace warptile
#endif