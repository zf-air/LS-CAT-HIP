#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void main_set(float *data, float val) {
data[threadIdx.x] = val;
}