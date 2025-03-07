#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void kDot_m1_m2T(const int nThreads, const float *m1, const float *m2, float *output, const int m1_columns, const int m2_rows ){
/*  Updates the output matrix with the product of two matrices: m1 and m2 transposed.
Inputs:
m1: array, left matrix of size m1_rows x m1_columns
m2: array, right matrix of size m2_rows x m1_columns (m2 transposed will be of size m1_columns x m2_rows)
output: array, the results of the computation are to be stored here:
m1 * m2, product of two arrays m1 and m2, a matrix of size m1_rows x m2_rows
m1_columns: int, number of columns in the left matrix m1
m2_rows: int, number of rows in the left matrix m2
*/

for (int i = blockIdx.x * blockDim.x + threadIdx.x;
i < nThreads;
i += blockDim.x * gridDim.x)
{
int r = (int)i / m2_rows;
int c = i % m2_rows;
float t_output = 0.0;
int id_T;

for( int k = 0; k < m1_columns; ++k ) {
id_T = c * m1_columns + k;
t_output += m1[ r * m1_columns + k ] * m2[ id_T ];
}

output[i] = t_output;
}
}