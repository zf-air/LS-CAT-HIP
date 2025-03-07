#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void BaseNeuronGetIntArray(int *arr1, int *arr2, int n_elem, int step1, int step2)
{
int array_idx = threadIdx.x + blockIdx.x * blockDim.x;
if (array_idx<n_elem) {
arr2[array_idx*step2] = arr1[array_idx*step1];
}
}