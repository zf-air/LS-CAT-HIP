#include "hip/hip_runtime.h"
#include "includes.h"

__global__ void render_init(int max_x, int max_y, hiprandState *rand_state) {
int i = threadIdx.x + blockIdx.x * blockDim.x;
int j = threadIdx.y + blockIdx.y * blockDim.y;
if ((i >= max_x) || (j >= max_y)) return;
int pixel_index = j * max_x + i;
hiprand_init(pixel_index, 0 , 0, &rand_state[pixel_index]);
}