#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <hiprand_kernel.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <sys/time.h>
#include "CombineScreen.cu"
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
float *d_postEdge1 = NULL;
hipMalloc(&d_postEdge1, XSIZE*YSIZE);
float *d_postEdge2 = NULL;
hipMalloc(&d_postEdge2, XSIZE*YSIZE);
float *d_postGradient1 = NULL;
hipMalloc(&d_postGradient1, XSIZE*YSIZE);
float *d_postGradient2 = NULL;
hipMalloc(&d_postGradient2, XSIZE*YSIZE);
float *d_postGradient3 = NULL;
hipMalloc(&d_postGradient3, XSIZE*YSIZE);
float *d_postSobel3LR = NULL;
hipMalloc(&d_postSobel3LR, XSIZE*YSIZE);
float *d_postSobel3UD = NULL;
hipMalloc(&d_postSobel3UD, XSIZE*YSIZE);
float *d_postSmooth31 = NULL;
hipMalloc(&d_postSmooth31, XSIZE*YSIZE);
float *d_output = NULL;
hipMalloc(&d_output, XSIZE*YSIZE);
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
CombineScreen<<<gridBlock,threadBlock>>>(d_postEdge1,d_postEdge2,d_postGradient1,d_postGradient2,d_postGradient3,d_postSobel3LR,d_postSobel3UD,d_postSmooth31,d_output);
hipDeviceSynchronize();
for (int loop_counter = 0; loop_counter < 10; ++loop_counter) {
CombineScreen<<<gridBlock,threadBlock>>>(d_postEdge1,d_postEdge2,d_postGradient1,d_postGradient2,d_postGradient3,d_postSobel3LR,d_postSobel3UD,d_postSmooth31,d_output);
}
auto start = steady_clock::now();
for (int loop_counter = 0; loop_counter < 1000; loop_counter++) {
CombineScreen<<<gridBlock,threadBlock>>>(d_postEdge1,d_postEdge2,d_postGradient1,d_postGradient2,d_postGradient3,d_postSobel3LR,d_postSobel3UD,d_postSmooth31,d_output);
}
auto end = steady_clock::now();
auto usecs = duration_cast<duration<float, microseconds::period> >(end - start);
cout <<'['<<usecs.count()<<','<<'('<<BLOCKX<<','<<BLOCKY<<')' << ','<<'('<<XSIZE<<','<<YSIZE<<')'<<']' << endl;
}
}}