#ifndef SUPPORT_H
#define SUPPORT_H
#include <cstdio>
#include <cuda_runtime.h>

#define TILE_WIDTH 32
#define BM_1d 64
#define BM_2d 64
#define BN_1d 64
#define BN_2d 64
#define BK_1d 64
#define BK_2d 64
#define TM_1d 64
#define TM_2d 64
#define TN_1d 64
#define TN_2d 64
#define PAD 64
#define BM 64
#define BN 64
#define BK 8
#define TM 4
#define TN 4

// support.h에 추가 (없으면)
#ifndef PAD_A_1D
// As: BK + PAD_A_1D 가 4의 배수 되게
#define PAD_A_1D  ((4 - (BK % 4)) & 3)
#endif

#ifndef PAD_B_1D
// Bs: BN_1d + PAD_B_1D 가 4의 배수 되게
#define PAD_B_1D  ((4 - (BN_1d % 4)) & 3)
#endif


#define CUDA_CHECK(x) do{ cudaError_t e=(x); if(e!=cudaSuccess){ \
  fprintf(stderr,"CUDA error %s:%d: %s\n",__FILE__,__LINE__,cudaGetErrorString(e)); \
  exit(1);} }while(0)

struct Timer {
  cudaEvent_t s,e;
  Timer(){ cudaEventCreate(&s); cudaEventCreate(&e); }
  ~Timer(){ cudaEventDestroy(s); cudaEventDestroy(e); }
};
inline void startTime(Timer& t){ cudaEventRecord(t.s); }
inline float stopTime(Timer& t){
  cudaEventRecord(t.e);
  cudaEventSynchronize(t.e);
  float ms=0;
  cudaEventElapsedTime(&ms,t.s,t.e);
  return ms;
}
#endif
