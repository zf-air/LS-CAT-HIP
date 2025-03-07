#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void stencil2DKernel(double* temperature, double* new_temperature, int block_x, int block_y, int thread_size) {
int i_start = (blockDim.x * blockIdx.x + threadIdx.x) * thread_size + 1;
int i_finish =
(blockDim.x * blockIdx.x + threadIdx.x) * thread_size + thread_size;
int j_start = (blockDim.y * blockIdx.y + threadIdx.y) * thread_size + 1;
int j_finish =
(blockDim.y * blockIdx.y + threadIdx.y) * thread_size + thread_size;

for (int i = i_start; i <= i_finish; i++) {
for (int j = j_start; j <= j_finish; j++) {
if (i <= block_x && j <= block_y) {
new_temperature[j * (block_x + 2) + i] =
(temperature[j * (block_x + 2) + (i - 1)] +
temperature[j * (block_x + 2) + (i + 1)] +
temperature[(j - 1) * (block_x + 2) + i] +
temperature[(j + 1) * (block_x + 2) + i] +
temperature[j * (block_x + 2) + i]) *
DIVIDEBY5;
}
}
}

/* TODO Use shared memory
int i = istart + threadIdx.x + blockDim.x*blockIdx.x;
int j = jstart + threadIdx.y + blockDim.y*blockIdx.y;

if (i < ifinish && j < jfinish) {
__shared__ double shared_temperature[TILE_SIZE][TILE_SIZE];
double center = temperature[j*(block_x+2)+i];

shared_temperature[threadIdx.x][threadIdx.y] = center;
__syncthreads();

// update my value based on the surrounding values
new_temperature[j*(block_x+2)+i] = (
((threadIdx.x > 1) ? shared_temperature[threadIdx.x-1][threadIdx.y] :
temperature[j*(block_x+2)+(i-1)]) +
((threadIdx.x < blockDim.x-1) ?
shared_temperature[threadIdx.x+1][threadIdx.y] :
temperature[j*(block_x+2)+(i+1)]) +
((threadIdx.y > 1) ? shared_temperature[threadIdx.x][threadIdx.y-1] :
temperature[(j-1)*(block_x+2)+i]) +
((threadIdx.y < blockDim.y-1) ?
shared_temperature[threadIdx.x][threadIdx.y+1] :
temperature[(j+1)*(block_x+2)+i]) +
center) * DIVIDEBY5;
}
*/
}