#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void STREAM_Scale_Optimized(float *a, float *b, float scale,  size_t len)
{
/*
* Ensure size of thread index space is as large as or greater than
* vector index space else return.
*/
if (blockDim.x * gridDim.x < len) return;
size_t idx = threadIdx.x + blockIdx.x * blockDim.x;
if (idx < len) b[idx] = scale* a[idx];
}