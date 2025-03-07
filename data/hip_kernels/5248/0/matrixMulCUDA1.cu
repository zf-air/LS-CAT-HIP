#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void matrixMulCUDA1(float *C, float *A, float *B, int n) { int k;  int row = threadIdx.y, col = threadIdx.x;  float sum = 0.0f;  for (k = 0; k < n; ++k) { sum += A[row * n + k] * B[k * n + col]; }  C[row * n + col] = sum; }