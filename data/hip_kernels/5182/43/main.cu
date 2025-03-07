#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <hiprand_kernel.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <sys/time.h>
#include "LSTMDeltaKernelBPTT.cu"
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
float *deltas = NULL;
hipMalloc(&deltas, XSIZE*YSIZE);
float *cellStates = NULL;
hipMalloc(&cellStates, XSIZE*YSIZE);
float *previousCellStates = NULL;
hipMalloc(&previousCellStates, XSIZE*YSIZE);
float *cellStateErrors = NULL;
hipMalloc(&cellStateErrors, XSIZE*YSIZE);
float *nextCellStateErrors = NULL;
hipMalloc(&nextCellStateErrors, XSIZE*YSIZE);
float *outputGateDeltas = NULL;
hipMalloc(&outputGateDeltas, XSIZE*YSIZE);
float *forgetGateDeltas = NULL;
hipMalloc(&forgetGateDeltas, XSIZE*YSIZE);
float *nextForgetGateDeltas = NULL;
hipMalloc(&nextForgetGateDeltas, XSIZE*YSIZE);
float *inputGateDeltas = NULL;
hipMalloc(&inputGateDeltas, XSIZE*YSIZE);
float *nextInputGateDeltas = NULL;
hipMalloc(&nextInputGateDeltas, XSIZE*YSIZE);
float *cellInputDeltas = NULL;
hipMalloc(&cellInputDeltas, XSIZE*YSIZE);
float *cellInputActivations = NULL;
hipMalloc(&cellInputActivations, XSIZE*YSIZE);
float *cellStateActivations = NULL;
hipMalloc(&cellStateActivations, XSIZE*YSIZE);
float *outputGateActivations = NULL;
hipMalloc(&outputGateActivations, XSIZE*YSIZE);
float *nextForgetGateActivations = NULL;
hipMalloc(&nextForgetGateActivations, XSIZE*YSIZE);
float *inputGateActivations = NULL;
hipMalloc(&inputGateActivations, XSIZE*YSIZE);
float *cellInputActivationDerivatives = NULL;
hipMalloc(&cellInputActivationDerivatives, XSIZE*YSIZE);
float *cellStateActivationDerivatives = NULL;
hipMalloc(&cellStateActivationDerivatives, XSIZE*YSIZE);
float *outputGateActivationDerivatives = NULL;
hipMalloc(&outputGateActivationDerivatives, XSIZE*YSIZE);
float *forgetGateActivationDerivatives = NULL;
hipMalloc(&forgetGateActivationDerivatives, XSIZE*YSIZE);
float *inputGateActivationDerivatives = NULL;
hipMalloc(&inputGateActivationDerivatives, XSIZE*YSIZE);
float *cellInputWeights = NULL;
hipMalloc(&cellInputWeights, XSIZE*YSIZE);
float *outputGateWeights = NULL;
hipMalloc(&outputGateWeights, XSIZE*YSIZE);
float *forgetGateWeights = NULL;
hipMalloc(&forgetGateWeights, XSIZE*YSIZE);
float *inputGateWeights = NULL;
hipMalloc(&inputGateWeights, XSIZE*YSIZE);
int inputCount = 1;
int cellCount = 1;
int cellsPerBlock = 1;
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
LSTMDeltaKernelBPTT<<<gridBlock,threadBlock>>>(deltas,cellStates,previousCellStates,cellStateErrors,nextCellStateErrors,outputGateDeltas,forgetGateDeltas,nextForgetGateDeltas,inputGateDeltas,nextInputGateDeltas,cellInputDeltas,cellInputActivations,cellStateActivations,outputGateActivations,nextForgetGateActivations,inputGateActivations,cellInputActivationDerivatives,cellStateActivationDerivatives,outputGateActivationDerivatives,forgetGateActivationDerivatives,inputGateActivationDerivatives,cellInputWeights,outputGateWeights,forgetGateWeights,inputGateWeights,inputCount,cellCount,cellsPerBlock);
hipDeviceSynchronize();
for (int loop_counter = 0; loop_counter < 10; ++loop_counter) {
LSTMDeltaKernelBPTT<<<gridBlock,threadBlock>>>(deltas,cellStates,previousCellStates,cellStateErrors,nextCellStateErrors,outputGateDeltas,forgetGateDeltas,nextForgetGateDeltas,inputGateDeltas,nextInputGateDeltas,cellInputDeltas,cellInputActivations,cellStateActivations,outputGateActivations,nextForgetGateActivations,inputGateActivations,cellInputActivationDerivatives,cellStateActivationDerivatives,outputGateActivationDerivatives,forgetGateActivationDerivatives,inputGateActivationDerivatives,cellInputWeights,outputGateWeights,forgetGateWeights,inputGateWeights,inputCount,cellCount,cellsPerBlock);
}
auto start = steady_clock::now();
for (int loop_counter = 0; loop_counter < 1000; loop_counter++) {
LSTMDeltaKernelBPTT<<<gridBlock,threadBlock>>>(deltas,cellStates,previousCellStates,cellStateErrors,nextCellStateErrors,outputGateDeltas,forgetGateDeltas,nextForgetGateDeltas,inputGateDeltas,nextInputGateDeltas,cellInputDeltas,cellInputActivations,cellStateActivations,outputGateActivations,nextForgetGateActivations,inputGateActivations,cellInputActivationDerivatives,cellStateActivationDerivatives,outputGateActivationDerivatives,forgetGateActivationDerivatives,inputGateActivationDerivatives,cellInputWeights,outputGateWeights,forgetGateWeights,inputGateWeights,inputCount,cellCount,cellsPerBlock);
}
auto end = steady_clock::now();
auto usecs = duration_cast<duration<float, microseconds::period> >(end - start);
cout <<'['<<usecs.count()<<','<<'('<<BLOCKX<<','<<BLOCKY<<')' << ','<<'('<<XSIZE<<','<<YSIZE<<')'<<']' << endl;
}
}}