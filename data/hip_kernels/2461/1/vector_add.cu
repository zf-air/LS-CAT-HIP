#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void vector_add(float *out, float *a, float *b, int n) {
printf("hi");
for(int i = 0; i < n; i ++){
out[i] = a[i] + b[i];
}
}