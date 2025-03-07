#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void callOperationSharedStatic(int *a, int *b, int x, int *res, int n)
{
int tid = blockDim.x * blockIdx.x + threadIdx.x;

if (tid >= n)
{
return;
}

__shared__ int s_a[size], s_b[size], s_res[size];
__shared__ int s_x;

s_x = x;
s_a[tid] = a[tid];
s_b[tid] = b[tid];

s_res[tid] = ((s_a[tid] * s_x) + s_b[tid]);
res[tid] = s_res[tid];
}