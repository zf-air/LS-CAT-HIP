#include "hip/hip_runtime.h"
#include "includes.h"
/**
* Various matrix utils using cuda
**/


/**
* Kronecker product of two matrices kernel
* input :
* a : first matrix
* nax, nay : matrix a dimensions
* b: second matrix
* nbx, nby : matrix b dimensions
* results : kronecker product of a and b
**/

__global__ void pick(size_t N , size_t * d_dst, unsigned long seed)
{
int myId = blockIdx.x * blockDim.x + threadIdx.x;
if (myId >= N)
return;
hiprandState state;
hiprand_init ( seed, myId, 0, &state);
float RANDOM = hiprand_uniform( &state );
d_dst[myId] = (size_t)(RANDOM * (N - 0.00001));
}