#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void compute_max_gpu(float *device_input, float *device_output){
extern __shared__ float sm[];

int tid = threadIdx.x;
int i = blockIdx.x * blockDim.x + threadIdx.x;

sm[tid] = device_input[i];
__syncthreads();

for(int s = 1;s < blockDim.x; s*= 2){
if(tid % (2 * s) == 0){
sm[tid] = max(sm[tid], sm[tid+s]);
}
__syncthreads();
}

if(tid == 0) device_output[blockIdx.x] = sm[0];
}