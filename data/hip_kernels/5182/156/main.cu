#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <hiprand_kernel.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <sys/time.h>
#include "FullyConnectedUpdateMovingAveragesKernel.cu"
#include<chrono>
#include<iostream>
using namespace std;
using namespace std::chrono;
int blocks_[20][2] = {{8,8},{16,16},{24,24},{32,32},{1,64},{1,128},{1,192},{1,256},{1,320},{1,384},{1,448},{1,512},{1,576},{1,640},{1,704},{1,768},{1,832},{1,896},{1,960},{1,1024}};
int matrices_[7][2] = {{240,240},{496,496},{784,784},{1016,1016},{1232,1232},{1680,1680},{2024,2024}};
int main(int argc, char **argv) {
hipSetDevice(0);
char* p;int matrix_len=strtol(argv[1], &p, 10);
for(int matrix_looper=0;matrix_looper<matrix_len;matrix_looper++){
for(int block_looper=0;block_looper<20;block_looper++){
int XSIZE=matrices_[matrix_looper][0],YSIZE=matrices_[matrix_looper][1],BLOCKX=blocks_[block_looper][0],BLOCKY=blocks_[block_looper][1];
float *weightsGradPtr = NULL;
hipMalloc(&weightsGradPtr, XSIZE*YSIZE);
float *biasGradPtr = NULL;
hipMalloc(&biasGradPtr, XSIZE*YSIZE);
float *weightsGradCurvePtr = NULL;
hipMalloc(&weightsGradCurvePtr, XSIZE*YSIZE);
float *biasGradCurvePtr = NULL;
hipMalloc(&biasGradCurvePtr, XSIZE*YSIZE);
float *avgWeightGradPtr = NULL;
hipMalloc(&avgWeightGradPtr, XSIZE*YSIZE);
float *avgBiasGradPtr = NULL;
hipMalloc(&avgBiasGradPtr, XSIZE*YSIZE);
float *avgWeightGradVarPtr = NULL;
hipMalloc(&avgWeightGradVarPtr, XSIZE*YSIZE);
float *avgBiasGradVarPtr = NULL;
hipMalloc(&avgBiasGradVarPtr, XSIZE*YSIZE);
float *avgWeightGradCurvePtr = NULL;
hipMalloc(&avgWeightGradCurvePtr, XSIZE*YSIZE);
float *avgBiasGradCurvePtr = NULL;
hipMalloc(&avgBiasGradCurvePtr, XSIZE*YSIZE);
float *avgWeightGradCurveVarPtr = NULL;
hipMalloc(&avgWeightGradCurveVarPtr, XSIZE*YSIZE);
float *avgBiasGradCurveVarPtr = NULL;
hipMalloc(&avgBiasGradCurveVarPtr, XSIZE*YSIZE);
float *weightMemorySizePtr = NULL;
hipMalloc(&weightMemorySizePtr, XSIZE*YSIZE);
float *biasMemorySizePtr = NULL;
hipMalloc(&biasMemorySizePtr, XSIZE*YSIZE);
float *dropoutMaskPtr = NULL;
hipMalloc(&dropoutMaskPtr, XSIZE*YSIZE);
int prevLayerSize = XSIZE*YSIZE;
int thisLayerSize = XSIZE*YSIZE;
int iXSIZE= XSIZE;
int iYSIZE= YSIZE;
while(iXSIZE%BLOCKX!=0)
{
iXSIZE++;
}
while(iYSIZE%BLOCKY!=0)
{
iYSIZE++;
}
dim3 gridBlock(iXSIZE/BLOCKX, iYSIZE/BLOCKY);
dim3 threadBlock(BLOCKX, BLOCKY);
hipFree(0);
FullyConnectedUpdateMovingAveragesKernel<<<gridBlock,threadBlock>>>(weightsGradPtr,biasGradPtr,weightsGradCurvePtr,biasGradCurvePtr,avgWeightGradPtr,avgBiasGradPtr,avgWeightGradVarPtr,avgBiasGradVarPtr,avgWeightGradCurvePtr,avgBiasGradCurvePtr,avgWeightGradCurveVarPtr,avgBiasGradCurveVarPtr,weightMemorySizePtr,biasMemorySizePtr,dropoutMaskPtr,prevLayerSize,thisLayerSize);
hipDeviceSynchronize();
for (int loop_counter = 0; loop_counter < 10; ++loop_counter) {
FullyConnectedUpdateMovingAveragesKernel<<<gridBlock,threadBlock>>>(weightsGradPtr,biasGradPtr,weightsGradCurvePtr,biasGradCurvePtr,avgWeightGradPtr,avgBiasGradPtr,avgWeightGradVarPtr,avgBiasGradVarPtr,avgWeightGradCurvePtr,avgBiasGradCurvePtr,avgWeightGradCurveVarPtr,avgBiasGradCurveVarPtr,weightMemorySizePtr,biasMemorySizePtr,dropoutMaskPtr,prevLayerSize,thisLayerSize);
}
auto start = steady_clock::now();
for (int loop_counter = 0; loop_counter < 1000; loop_counter++) {
FullyConnectedUpdateMovingAveragesKernel<<<gridBlock,threadBlock>>>(weightsGradPtr,biasGradPtr,weightsGradCurvePtr,biasGradCurvePtr,avgWeightGradPtr,avgBiasGradPtr,avgWeightGradVarPtr,avgBiasGradVarPtr,avgWeightGradCurvePtr,avgBiasGradCurvePtr,avgWeightGradCurveVarPtr,avgBiasGradCurveVarPtr,weightMemorySizePtr,biasMemorySizePtr,dropoutMaskPtr,prevLayerSize,thisLayerSize);
}
auto end = steady_clock::now();
auto usecs = duration_cast<duration<float, microseconds::period> >(end - start);
cout <<'['<<usecs.count()<<','<<'('<<BLOCKX<<','<<BLOCKY<<')' << ','<<'('<<XSIZE<<','<<YSIZE<<')'<<']' << endl;
}
}}