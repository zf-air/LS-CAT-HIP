#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void yMaxDeltaIntegralReplicateKernel( const float *intData, float *tmpArray, const int nWindows, const int h, const int w, const float *xMin, const float *xMax, const float *yMax, const int strideH, const int strideW) {

// TODO: use block dim instead
const int hOut = (h + strideH - 1) / strideH;
const int wOut = (w + strideW - 1) / strideW;

int id = BLOCK_SIZE * BLOCK_SIZE * blockIdx.x + threadIdx.x;
const int yOut = id % wOut; id /= wOut; // 0-indexed
const int xOut = id % hOut; id /= hOut; // 0-indexed
const int & windowIdx = id;

if (windowIdx < nWindows and xOut < hOut and yOut < wOut) {

const int x = xOut*strideH + 1;
const int y = yOut*strideW + 1;

tmpArray += windowIdx * hOut * wOut;

const int xMinInt = (int)ceil(xMin[windowIdx]-1);
// const int yMinInt = (int)ceil(yMin[windowIdx]-1);
const int xMaxInt = (int)floor(xMax[windowIdx]);
const int yMaxInt = (int)floor(yMax[windowIdx]);

float delta = 0;

delta +=
intData[max(0,min(x+xMaxInt, h))*(w+1)
+ max(1,min(y+yMaxInt+1, w))];
delta -=
intData[max(0,min(x+xMaxInt, h))*(w+1)
+ max(0,min(y+yMaxInt  , w))];
delta -=
intData[max(0,min(x+xMinInt, h))*(w+1)
+ max(1,min(y+yMaxInt+1, w))];
delta +=
intData[max(0,min(x+xMinInt, h))*(w+1)
+ max(0,min(y+yMaxInt  , w))];

delta *= (y+yMaxInt >= 1 and y+yMaxInt < w);
tmpArray[xOut*wOut + yOut] = delta;
}
}