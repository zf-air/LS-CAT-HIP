#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void __pairmult2(int nrows, int bncols, int brows1, int brows2, float *A, int lda, float *A2, int lda2, float *Bdata, int *Bir, int *Bjc, int broff, int bcoff, float *C, int ldc, int transpose) {}