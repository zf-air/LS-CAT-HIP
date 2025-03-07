#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void matrixMulCUDA2(float *C, float *A, float *B, int n) { int row = blockIdx.y * blockDim.y + threadIdx.y;  int col = blockIdx.x * blockDim.x + threadIdx.x;  float C_val = 0;  for (int k = 0; k < n; ++k) { float A_elem = A[row * n + k];   float B_elem = B[k * n + col];   C_val += A_elem * B_elem; }  C[row*n + col] = C_val; }