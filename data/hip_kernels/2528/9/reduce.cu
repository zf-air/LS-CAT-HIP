#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void reduce(float *g_idata, float *g_odata){
extern __shared__ float sdata[];

//each thread loads one element from global to shared mem
unsigned int tid = threadIdx.x;
unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;
sdata[tid] = g_idata[i];
__syncthreads();

// do reduction in shared mem
for(unsigned int s = 1;s < blockDim.x; s *= 2){
if(tid % (2 * s) == 0){
sdata[tid] += sdata[tid + s];
}
__syncthreads();
}

// write result for this block to global mem
if (tid == 0) g_odata[blockIdx.x] = sdata[0];
}