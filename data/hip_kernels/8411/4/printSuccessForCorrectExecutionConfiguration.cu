#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void printSuccessForCorrectExecutionConfiguration()
{

if(threadIdx.x == 1023 && blockIdx.x == 255)
{
printf("Success!\n");
}
}