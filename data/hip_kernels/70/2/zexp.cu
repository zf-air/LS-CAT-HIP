#include "hip/hip_runtime.h"
#include "includes.h"
/***********************************************************
By Huahua Wang, the University of Minnesota, twin cities
***********************************************************/












__global__ void zexp( float* Z, float* X, float* Y, unsigned int size)
{
const unsigned int idx = blockIdx.x * blockDim.x + threadIdx.x;
const unsigned int stride = blockDim.x * gridDim.x;

for (unsigned long int i = idx; i < size; i += stride) {
Z[i] = X[i]*__expf(Y[i]);
}
}