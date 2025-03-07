#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void gpu_imageSquare(float * out, const float * in, const int width, const int height) {

const int x = blockIdx.x*blockDim.x + threadIdx.x;
const int y = blockIdx.y*blockDim.y + threadIdx.y;

if (x >= width || y >= height) {
return;
}

int index = x + y*width;
out[index] = in[index]*in[index];

}