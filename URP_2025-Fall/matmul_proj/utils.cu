#include <stdlib.h>
#include <stdio.h>
#include <cmath>
#include <cstdio>

#include "support.h"

void genData(float* ptr, unsigned int size) {
    for (unsigned int i = 0; i < size; ++i) {
        ptr[i] = (float)(i % 100) / 10.0f;
    }
}

void matmul_cpu(float* C, const float* A, const float* B, int M, int N, int K){
    for (int i=0; i<M; ++i){
        for (int j=0; j<N; ++j){
            float sum = 0.0f;
            for (int k=0; k<K; ++k){
                sum += A[i*K + k] * B[k*N + j];
            }
            C[i*N + j] = sum;
        }
    }
}

void startTime(Timer* timer) {
    gettimeofday(&(timer->startTime), NULL);
}

void stopTime(Timer* timer) {
    gettimeofday(&(timer->endTime), NULL);
}

float elapsedTime(Timer timer) {
    return ((float) ((timer.endTime.tv_sec - timer.startTime.tv_sec) \
                + (timer.endTime.tv_usec - timer.startTime.tv_usec)/1.0e6));
}

bool compareResults(const float* ref, const float* test, int size, float tol) {
    for (int i = 0; i < size; ++i) {
        float diff = fabs(ref[i] - test[i]); //float absolute value
        if (diff > tol) {
            printf("Mismatch at index %d: ref=%.6f, test=%.6f, diff=%.6f\n",
                   i, ref[i], test[i], diff);
            return false;
        }
    }
    printf("CPU and GPU results match within tolerance (%.1e).\n", tol);
    return true;
}