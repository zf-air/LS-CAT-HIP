#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void vecAddKernel(float* A, float* B, float* C, int n) {

// Calculate global thread index based on the block and thread indices ----

//INSERT KERNEL CODE HERE
int i = blockDim.x*blockIdx.x+threadIdx.x;

// Use global index to determine which elements to read, add, and write ---

//INSERT KERNEL CODE HERE

if (i<n) C[i] = A[i] + B[i];

}