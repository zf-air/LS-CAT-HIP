#include "hip/hip_runtime.h"
#include "includes.h"
__global__  void Multiply(float* im, float val, int size)
{
int id = blockDim.x*blockIdx.y*gridDim.x + blockDim.x*blockIdx.x + threadIdx.x;
if (id < size)
im[id] *= val;
}