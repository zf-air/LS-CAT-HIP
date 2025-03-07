#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void upsampleFilterForegroundMaskKernel( hipTextureObject_t subsampled_mask, unsigned upsample_rows, unsigned upsample_cols, unsigned sample_rate, const float sigma, hipSurfaceObject_t upsampled_mask, hipSurfaceObject_t filter_mask ) {
const int x = threadIdx.x + blockDim.x * blockIdx.x;
const int y = threadIdx.y + blockDim.y * blockIdx.y;
if(x >= upsample_cols || y >= upsample_rows) return;

//A window search
const int halfsize = __float2uint_ru(sigma) * 2;
float total_weight = 0.0f;
float total_value = 0.0f;
for(int neighbor_y = y - halfsize; neighbor_y <= y + halfsize; neighbor_y++) {
for(int neighbor_x = x - halfsize; neighbor_x <= x + halfsize; neighbor_x++) {
//Retrieve the mask value at neigbour
const auto subsampled_neighbor_x = neighbor_x / sample_rate;
const auto subsampled_neighbor_y = neighbor_y / sample_rate;
const unsigned char neighbor_foreground = tex2D<unsigned char>(subsampled_mask, subsampled_neighbor_x, subsampled_neighbor_y);

//Compute the gaussian weight
const float diff_x_square = (neighbor_x - x) * (neighbor_x - x);
const float diff_y_square = (neighbor_y - y) * (neighbor_y - y);
const float weight = __expf(0.5f * (diff_x_square + diff_y_square) / (sigma * sigma));

//Accumlate it
if(neighbor_x >= 0 && neighbor_x < upsample_cols && neighbor_y >= 0 && neighbor_y < upsample_rows)
{
total_weight += weight;
total_value += weight * float(1 - neighbor_foreground);
}
}
}


//Compute the value locally
const auto subsampled_x = x / sample_rate;
const auto subsampled_y = y / sample_rate;
const unsigned char foreground_indicator = tex2D<unsigned char>(subsampled_mask, subsampled_x, subsampled_y);
float filter_value = 0.0;
if(foreground_indicator == 0) {
filter_value = total_value / (total_weight + 1e-3f);
}


//Write to the surface
surf2Dwrite(foreground_indicator, upsampled_mask, x * sizeof(unsigned char), y);
surf2Dwrite(filter_value, filter_mask, x * sizeof(float), y);
}