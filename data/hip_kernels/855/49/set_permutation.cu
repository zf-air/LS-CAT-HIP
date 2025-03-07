#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void set_permutation(int *d_permutation, int M)
{
int i = blockIdx.x * blockDim.x + threadIdx.x;

if (i >= M) {
return;
}

d_permutation[i] = i;
}