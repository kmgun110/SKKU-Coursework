#include <stdlib.h>
#include <stdio.h>
#include <cmath>
#include <cstdio>
#include "support.h"

__global__ void naive_matmul(int M, int N, int K, const float *A, const float* B, float* C)
{
  const int x = blockIdx.x * blockDim.x + threadIdx.x;
  const int y = blockIdx.y * blockDim.y + threadIdx.y;

  if (x < M && y < N)
  {
    float sum = 0.0;
    for (int i = 0; i < K; i++)
    {
      sum += A[x * K + i] * B[i * N + y];
    }
    C[x * N + y] = 1.0 * sum + 0.0 * C[x * N + y];
  }
}

__global__ void matmul_shared(float* g_C, const float* g_A, const float* g_B, const int M, 
  const int N, const int K) {
    __shared__ float As[TILE_WIDTH][TILE_WIDTH];
    __shared__ float Bs[TILE_WIDTH][TILE_WIDTH + 1];

    int tx = threadIdx.x; int ty = threadIdx.y;
    int bx = blockIdx.x; int by = blockIdx.y;

    int col = bx * TILE_WIDTH + tx;
    int row = by * TILE_WIDTH + ty;

    float sum = 0.0f;
    int numTiles = (K + TILE_WIDTH -1) / TILE_WIDTH;
    for (int m=0; m<numTiles; ++m)
    {
       const int a_col = m * TILE_WIDTH + tx;
       const int b_row = m * TILE_WIDTH + ty;

       As[ty][tx] = (row < M && a_col < K) ? g_A[row * K + a_col] : 0.0f;
       Bs[ty][tx] = (b_row < K && col < N) ? g_B[b_row * N + col] : 0.0f;

        __syncthreads();

        for (int k = 0; k < TILE_WIDTH; k++)
        {
          sum += As[ty][k] * Bs[k][tx];
        }

        __syncthreads();
    }

    if (row < M && col < N) {
        g_C[row*N + col] = 1.0 *sum + 0.0 *g_C[row*N + col];
    }
}


__global__ void matmul_1D_blocktile_(float* C, const float* A, const float* B, int M, int N, int K) {
    __shared__ float As[BM_1d][BK+1];
    __shared__ float Bs[BK][BN_1d+1];

    int blockRow = blockIdx.y; 
    int blockCol = blockIdx.x; 

    int tid = threadIdx.x;

    int colsPerThreadGroup = BN_1d / TM;  // 64 / 8 = 8

    // local coordinate
    int localRow  = tid / colsPerThreadGroup;        // 0..63
    int localCol0 = (tid % colsPerThreadGroup) * TM; // 0,8,16,...56

    int row = blockRow * BM_1d + localRow;
    int col0 = blockCol * BN_1d + localCol0;

    float regC[TM] = {0.0f};

    for (int bk = 0; bk < K; bk += BK) {
        if (row < M && (bk + threadIdx.x % BK) < K) {
            int loadCol = bk + (tid % BK);
            int loadRow = tid / BK;
            if (loadRow < BM_1d && (blockRow*BM_1d + loadRow) < M && loadCol < K)
                As[loadRow][tid % BK] = A[(blockRow*BM_1d + loadRow)*K + loadCol];
        }

        if (col0 < N && (bk + tid / BN_1d) < K) {
            int loadRow = tid / BN_1d;
            int loadCol = tid % BN_1d;
            if (loadRow < BK && (bk + loadRow) < K && (blockCol*BN_1d + loadCol) < N)
                Bs[loadRow][loadCol] = B[(bk + loadRow)*N + (blockCol*BN_1d + loadCol)];
        }

        __syncthreads();

        if (row < M) {
            for (int kInner = 0; kInner < BK; kInner++) {
                float aVal = As[localRow][kInner];
                for (int t = 0; t < TM; t++) {
                  if (col0 + t < N)
                    regC[t] += aVal * Bs[kInner][localCol0 + t];
                }
            }
        }
        __syncthreads();
    }

    if (row < M) {
        for (int t = 0; t < TM; t++) {
            if (col0 + t < N)
                C[row * N + (col0 + t)] = regC[t];
        }
    }
}


__global__ void matmul_2D_blocktile(
    float* __restrict__ C,           // MxN
    const float* __restrict__ A,     // MxK
    const float* __restrict__ B,     // KxN
    int M, int N, int K)
{
    static_assert(BM % TM == 0, "BM must be multiple of TM");
    static_assert(BN % TN == 0, "BN must be multiple of TN");

    const int blockRow0 = blockIdx.y * BM;
    const int blockCol0 = blockIdx.x * BN;

    //const int numThreadRows = BM / TM;  // 128/8 = 16
    const int numThreadCols = BN / TN;  // 128/8 = 16
    const int tid       = threadIdx.x;
    const int threadRow = tid / numThreadCols;       // 0..15
    const int threadCol = tid % numThreadCols;       // 0..15

    const int cRowBase = blockRow0 + threadRow * TM;
    const int cColBase = blockCol0 + threadCol * TN;

    float accum[TM * TN];
    #pragma unroll
    for (int i = 0; i < TM*TN; ++i) accum[i] = 0.0f;

    __shared__ float As[BM * BK];  // 128 x 8
    __shared__ float Bs[BK * BN];  //   8 x 128

    const int tpb = blockDim.x;    // 256

    for (int k0 = 0; k0 < K; k0 += BK) {

        for (int idx = tid; idx < BM * BK; idx += tpb) {
            int r = idx / BK;              // 0..BM-1
            int c = idx % BK;              // 0..BK-1
            int gRow = blockRow0 + r;
            int gCol = k0 + c;
            float v = 0.f;
            if (gRow < M && gCol < K) v = A[gRow * K + gCol];
            As[r * BK + c] = v;
        }

        for (int idx = tid; idx < BK * BN; idx += tpb) {
            int r = idx / BN;              // 0..BK-1
            int c = idx % BN;              // 0..BN-1
            int gRow = k0 + r;
            int gCol = blockCol0 + c;
            float v = 0.f;
            if (gRow < K && gCol < N) v = B[gRow * N + gCol];
            Bs[r * BN + c] = v;
        }

        __syncthreads(); 

        #pragma unroll
        for (int kk = 0; kk < BK; ++kk) {
            float regM[TM];
            float regN[TN];

            #pragma unroll
            for (int i = 0; i < TM; ++i) {
                int aRow = threadRow * TM + i;       // 0..127
                regM[i] = As[aRow * BK + kk];
            }

            #pragma unroll
            for (int j = 0; j < TN; ++j) {
                int bCol = threadCol * TN + j;       // 0..127
                regN[j] = Bs[kk * BN + bCol];
            }
            // 외적 누적
            #pragma unroll
            for (int i = 0; i < TM; ++i) {
                #pragma unroll
                for (int j = 0; j < TN; ++j) {
                    accum[i*TN + j] += regM[i] * regN[j];
                }
            }
        }

        __syncthreads(); 
    }

    #pragma unroll
    for (int i = 0; i < TM; ++i) {
        int r = cRowBase + i;
        if (r >= M) break;
        #pragma unroll
        for (int j = 0; j < TN; ++j) {
            int c = cColBase + j;
            if (c >= N) break;
            C[r * N + c] = accum[i*TN + j];
        }
    }
}


__global__ void matmul_2D_blocktile_at(float* g_C, const float* g_A, const float* g_B, const int M, const int N, const int K) {
  const uint cRow = blockIdx.y;
  const uint cCol = blockIdx.x;

  const int threadCol = threadIdx.x % (BN / TN);
  const int threadRow = threadIdx.x / (BN/TN);

  __shared__ float tileA[BM * BK];
  __shared__ float tileB[BK * BN];

  // To implement local indexing in kernel //
  // Move blocktile to beginning of A's row and B's col//
  g_A += cRow * BM * K; // tiling한 부분
  g_B += cCol * BN;
  g_C += cRow* BM *N + cCol * BN;

  // calculating the indices that this thread will load into SMEM
  // load 128bit / 32 bit = 4 elements per thread at each step
  const uint threadRowA = threadIdx.x / (BK/4);
  const uint threadColA = threadIdx.x % (BK/4);
  const uint threadRowB = threadIdx.x / (BN/4);
  const uint threadColB = threadIdx.x % (BN/4);

  // allocate thread-local cache for results in reg file
  float threadResults[TM * TN] = {0.0};
  float regM[TM] = {0.0};
  float regN[TN] = {0.0};

  for (uint bk=0; bk<K; bk += BK) {
    // load A, B to shared mem
    // transpose A while loading it
    float4 tmp = reinterpret_cast<const float4 *>(&g_A[threadRowA * K + threadColA * 4])[0];
    tileA[(threadColA * 4 + 0) * BM + threadRowA] = tmp.x;
    tileA[(threadColA * 4 + 1)* BM + threadRowA] = tmp.y;
    tileA[(threadColA * 4 + 2) * BM + threadRowA] = tmp.z;
    tileA[(threadColA * 4 + 3) * BM + threadRowA] = tmp.w;

    reinterpret_cast<float4 *>(&tileB[threadRowB * BN + threadColB * 4])[0] = reinterpret_cast<const float4 *>(&g_B[threadRowB * N + threadColB * 4])[0];
    __syncthreads();

    // mv blocktile
    g_A += BK; // move BK columns to right
    g_B += BK * N; // move BK rows down

    // calculate per-thread results
    for (uint bk=0; bk<BK; ++bk){
      // caching row values to reg file
      for (uint i=0; i<TM; ++i){
        regM[i] = tileA[bk*BM + threadRow * TM + i];
      }
      for (uint i=0; i<TN; ++i){
        regN[i] = tileB[bk*BN + threadCol * TN + i];
      }
      for (uint tm=0; tm<TM; ++tm){
        for (uint tn=0; tn<TN; ++tn){
          threadResults[tm*TN + tn] += regM[tm] * regN[tn];
        }
      }
    }
    __syncthreads();
  }
  // write out the results
  for (uint tm=0; tm<TM; tm += 1){
    for (uint tn=0; tn<TN; tn += 4){
      // load C vector into regs
      float4 tmp = reinterpret_cast<float4 *>(&g_C[(threadRow * TM + tm)* N + threadCol * TN + tn])[0];
      // (article : alpha, beta도 포함)
      tmp.x = threadResults[tm * TN + tn];
      tmp.y = threadResults[tm * TN + tn + 1];
      tmp.z = threadResults[tm * TN + tn + 2];
      tmp.w = threadResults[tm * TN + tn + 3];
      // write back
      reinterpret_cast<float4 *>(&g_C[(threadRow * TM + tm)*N + threadCol*TN + tn])[0] = tmp;
    }
  }
}

///// Warp Tiling /////
__global__ void matmul_warptile(float* g_C, const float* g_A, const float* g_B, const int M, const int N, const int K) {
  // (per SM)
  const uint cRow = blockIdx.y;
  const uint cCol = blockIdx.x;

  // placement of the warp in the threadblock tile (per SM, idx of each warp)
  const uint warpIdx = threadIdx.x / 32; // assumed warpsize is 32
  const uint warpCol = warpIdx % (w_BN/WN); // each SM
  const uint warpRow = warpIdx / (w_BN/WN);

  // size of the warp subtile
  constexpr uint WMITER = (WM * WN) / (32 * w_TM * w_TN * WNITER);
  constexpr uint WSUBM = WM / WMITER; //64/2 = 32
  constexpr uint WSUBN = WN / WNITER; //32/2 = 16

  // Placement of the thread in the warp subtile (per Warp)
  const uint threadIdxInWarp = threadIdx.x % 32;
  const uint threadColInWarp = threadIdxInWarp % (WSUBN/w_TN); // i%(16/4)
  const uint threadRowInWarp = threadIdxInWarp / (WSUBN/w_TN); // i/4

  // allocate space for the current blocktile in SMEM
  __shared__ float tileA[w_BM * w_BK];
  __shared__ float tileB[w_BK * w_BN];

  // Move blocktile to beginning of A's row and B's column (per SM)
  g_A += cRow * w_BM * K;
  g_B += cCol * w_BN;
  // move C_ptr to warp's output tile (warp 단위로 실행되니까 이렇게 하는듯)
  g_C += (cRow * w_BM  + warpRow * WM)*N + cCol * w_BN + warpCol * WN; // (per Warp)

  // now : NUM_THREADS = 128 
  // calculating the indices that this thread will load into SMEM (per SM)
  // load 128bit / 32bit = 4 elements per thread at each step
  const uint threadRowA = threadIdx.x / (w_BK/4);
  const uint threadColA = threadIdx.x % (w_BK/4);
  const uint threadRowB = threadIdx.x / (w_BN/4);
  const uint threadColB = threadIdx.x % (w_BN/4);

  constexpr uint rowStrideA = (NUM_THREADS * 4)/w_BK; // each thread loads 4 elements
  constexpr uint rowStrideB = (NUM_THREADS * 4)/w_BN;

  // allocate thread-local cache for results in reg file (per Warp)
  float threadResults[(WMITER * w_TM) * (WNITER * w_TN)] = {0.0};
  // cache into regs on the warptile level (per Warp)
  float regM[WMITER * w_TM] = {0.0};
  float regN[WNITER * w_TN] = {0.0};

  // outer-most loop over block tiles (per SM)
  for (uint bkIdx=0; bkIdx < K; bkIdx += w_BK){
    warptile::loadFromGmem<rowStrideA, rowStrideB>(N, K, g_A, g_B, tileA, tileB, threadRowA, threadColA, threadRowB, threadColB);
    __syncthreads();
    warptile::processFromSmem<WMITER, WSUBM, WSUBN>(regM, regN, threadResults, tileA, tileB, warpRow, warpCol, threadRowInWarp, threadColInWarp);
    g_A += w_BK; // move BK columns to right
    g_B += w_BK * N; // move BK rows down
    __syncthreads();
  }

  // write out the results
  for (uint wSubRowIdx = 0; wSubRowIdx < WMITER; ++wSubRowIdx){
    for (uint wSubColIdx = 0; wSubColIdx < WNITER; ++wSubColIdx){
      // move C pointer to current warp subtile
      float *g_C_interim = g_C + (wSubRowIdx * WSUBM)* N + wSubColIdx * WSUBN;
      for (uint resIdxM = 0; resIdxM < w_TM; resIdxM += 1) {
        for (uint resIdxN = 0; resIdxN < w_TN; resIdxN += 4){
          // load C vector into reg
          float4 tmp = reinterpret_cast<float4 *>(&g_C_interim[(threadRowInWarp * w_TM + resIdxM)*N + threadColInWarp*w_TN + resIdxN])[0];
          // perform GEMM update in reg
          const int i = (wSubRowIdx * w_TM + resIdxM)*(WNITER * w_TN) + wSubColIdx * w_TN + resIdxN; //WNITER * TN 곱하는게 이해가 안됨. 왜 WN 곱하는게 없지..?
          tmp.x = threadResults[i+0];
          tmp.y = threadResults[i+1];
          tmp.z = threadResults[i+2];
          tmp.w = threadResults[i+3];
          //write back
          reinterpret_cast<float4 *>(&g_C_interim[(threadRowInWarp * w_TM +resIdxM)*N + threadColInWarp*w_TN + resIdxN])[0] = tmp;
        }
      }
    }
  }

}
