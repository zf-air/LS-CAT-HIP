#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void decryptKernel(char* deviceDataIn, char* deviceDataOut, int n) {
unsigned index = blockIdx.x * blockDim.x + threadIdx.x;
if (index < n)
deviceDataOut[index] = deviceDataIn[index]-1;
}