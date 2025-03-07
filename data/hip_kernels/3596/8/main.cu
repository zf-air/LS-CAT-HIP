#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <hiprand_kernel.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <sys/time.h>
#include "MHDComputedUz_CUDA3_kernel.cu"
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
float *FluxD = NULL;
hipMalloc(&FluxD, XSIZE*YSIZE);
float *FluxS1 = NULL;
hipMalloc(&FluxS1, XSIZE*YSIZE);
float *FluxS2 = NULL;
hipMalloc(&FluxS2, XSIZE*YSIZE);
float *FluxS3 = NULL;
hipMalloc(&FluxS3, XSIZE*YSIZE);
float *FluxTau = NULL;
hipMalloc(&FluxTau, XSIZE*YSIZE);
float *FluxBx = NULL;
hipMalloc(&FluxBx, XSIZE*YSIZE);
float *FluxBy = NULL;
hipMalloc(&FluxBy, XSIZE*YSIZE);
float *FluxBz = NULL;
hipMalloc(&FluxBz, XSIZE*YSIZE);
float *FluxPhi = NULL;
hipMalloc(&FluxPhi, XSIZE*YSIZE);
float *dUD = NULL;
hipMalloc(&dUD, XSIZE*YSIZE);
float *dUS1 = NULL;
hipMalloc(&dUS1, XSIZE*YSIZE);
float *dUS2 = NULL;
hipMalloc(&dUS2, XSIZE*YSIZE);
float *dUS3 = NULL;
hipMalloc(&dUS3, XSIZE*YSIZE);
float *dUTau = NULL;
hipMalloc(&dUTau, XSIZE*YSIZE);
float *dUBx = NULL;
hipMalloc(&dUBx, XSIZE*YSIZE);
float *dUBy = NULL;
hipMalloc(&dUBy, XSIZE*YSIZE);
float *dUBz = NULL;
hipMalloc(&dUBz, XSIZE*YSIZE);
float *dUPhi = NULL;
hipMalloc(&dUPhi, XSIZE*YSIZE);
float dtdx = 1;
int size = XSIZE*YSIZE;
int dim0 = 1;
int dim1 = 1;
int dim2 = 1;
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
MHDComputedUz_CUDA3_kernel<<<gridBlock,threadBlock>>>(FluxD,FluxS1,FluxS2,FluxS3,FluxTau,FluxBx,FluxBy,FluxBz,FluxPhi,dUD,dUS1,dUS2,dUS3,dUTau,dUBx,dUBy,dUBz,dUPhi,dtdx,size,dim0,dim1,dim2);
hipDeviceSynchronize();
for (int loop_counter = 0; loop_counter < 10; ++loop_counter) {
MHDComputedUz_CUDA3_kernel<<<gridBlock,threadBlock>>>(FluxD,FluxS1,FluxS2,FluxS3,FluxTau,FluxBx,FluxBy,FluxBz,FluxPhi,dUD,dUS1,dUS2,dUS3,dUTau,dUBx,dUBy,dUBz,dUPhi,dtdx,size,dim0,dim1,dim2);
}
auto start = steady_clock::now();
for (int loop_counter = 0; loop_counter < 1000; loop_counter++) {
MHDComputedUz_CUDA3_kernel<<<gridBlock,threadBlock>>>(FluxD,FluxS1,FluxS2,FluxS3,FluxTau,FluxBx,FluxBy,FluxBz,FluxPhi,dUD,dUS1,dUS2,dUS3,dUTau,dUBx,dUBy,dUBz,dUPhi,dtdx,size,dim0,dim1,dim2);
}
auto end = steady_clock::now();
auto usecs = duration_cast<duration<float, microseconds::period> >(end - start);
cout <<'['<<usecs.count()<<','<<'('<<BLOCKX<<','<<BLOCKY<<')' << ','<<'('<<XSIZE<<','<<YSIZE<<')'<<']' << endl;
}
}}