#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void cugen_curand_array(hiprandState_t * states_d, int * array_d, size_t size) {
int idx = threadIdx.x + blockIdx.x * blockDim.x;
if(idx < size) {
int r = hiprand_uniform(&states_d[idx]) * 100;
array_d[idx] = r;
}
}