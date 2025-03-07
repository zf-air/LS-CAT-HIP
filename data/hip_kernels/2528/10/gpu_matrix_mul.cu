#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void gpu_matrix_mul(int *a, int *b, int *c){

int row = blockIdx.y * blockDim.y + threadIdx.y;
int col = blockIdx.x * blockDim.x + threadIdx.x;
int sum = 0;
if(col < N && row < N){
for(int i = 0;i < N; i++){
sum += a[row*N + i] * b[i*N + col];
}
c[row*N + col] = sum;
}
}