#include "hip/hip_runtime.h"
#include "includes.h"
/**
* Given a input tensor x with shape (N, C, D), compute x.mean(2).mean(0)
* This function is useful in batch normalization.
* Refer to https://people.maths.ox.ac.uk/gilesm/cuda/prac4/reduction.pdf.
* But the unrolling warps seems to be not working correctly for now.
*/



const int N = 256;
const int C = 1024;
const int D = 28*28;

__global__ void reduce1(const float* in, float* out) {
__shared__ float buffer[CUDA_NUM_THREADS];
const unsigned int tid = threadIdx.x;
const unsigned int c = blockIdx.x;

// load and accumulate data to buffer
buffer[tid] = 0;
for (int i = tid; i < N * D; i += blockDim.x) {
const unsigned int n = i / D;
const unsigned int d = i % D;
const unsigned int index = n * C * D + c * D + d;
buffer[tid] += in[index];
}
__syncthreads();

// do tree reduction in buffer
for (int s = 1; s < blockDim.x; s *= 2) {
const int index = 2 * s * tid;
if (index < blockDim.x) {  // <-- bad: shared memory bank conflicts
buffer[index] += buffer[index + s];
}
__syncthreads();
}

if (tid == 0) out[c] = buffer[0] / (N * D);
}