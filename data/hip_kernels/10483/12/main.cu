#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <hiprand_kernel.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <sys/time.h>
#include "mteKernel.cu"
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
int noPaths = 1;
int nYears = 1;
int noPatches = 1;
float timeStep = 1;
float *rgr = NULL;
hipMalloc(&rgr, XSIZE*YSIZE);
float *brownians = NULL;
hipMalloc(&brownians, XSIZE*YSIZE);
float *jumpSizes = NULL;
hipMalloc(&jumpSizes, XSIZE*YSIZE);
float *jumps = NULL;
hipMalloc(&jumps, XSIZE*YSIZE);
float *speciesParams = NULL;
hipMalloc(&speciesParams, XSIZE*YSIZE);
float *initPops = NULL;
hipMalloc(&initPops, XSIZE*YSIZE);
float *caps = NULL;
hipMalloc(&caps, XSIZE*YSIZE);
float *mmm = NULL;
hipMalloc(&mmm, XSIZE*YSIZE);
int *rowIdx = NULL;
hipMalloc(&rowIdx, XSIZE*YSIZE);
int *elemsPerCol = NULL;
hipMalloc(&elemsPerCol, XSIZE*YSIZE);
float *pathPops = NULL;
hipMalloc(&pathPops, XSIZE*YSIZE);
float *eps = NULL;
hipMalloc(&eps, XSIZE*YSIZE);
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
mteKernel<<<gridBlock,threadBlock>>>(noPaths,nYears,noPatches,timeStep,rgr,brownians,jumpSizes,jumps,speciesParams,initPops,caps,mmm,rowIdx,elemsPerCol,pathPops,eps);
hipDeviceSynchronize();
for (int loop_counter = 0; loop_counter < 10; ++loop_counter) {
mteKernel<<<gridBlock,threadBlock>>>(noPaths,nYears,noPatches,timeStep,rgr,brownians,jumpSizes,jumps,speciesParams,initPops,caps,mmm,rowIdx,elemsPerCol,pathPops,eps);
}
auto start = steady_clock::now();
for (int loop_counter = 0; loop_counter < 1000; loop_counter++) {
mteKernel<<<gridBlock,threadBlock>>>(noPaths,nYears,noPatches,timeStep,rgr,brownians,jumpSizes,jumps,speciesParams,initPops,caps,mmm,rowIdx,elemsPerCol,pathPops,eps);
}
auto end = steady_clock::now();
auto usecs = duration_cast<duration<float, microseconds::period> >(end - start);
cout <<'['<<usecs.count()<<','<<'('<<BLOCKX<<','<<BLOCKY<<')' << ','<<'('<<XSIZE<<','<<YSIZE<<')'<<']' << endl;
}
}}