#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <hiprand_kernel.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <sys/time.h>
#include "hotspotOpt1.cu"
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
float *p = NULL;
hipMalloc(&p, XSIZE*YSIZE);
float *tIn = NULL;
hipMalloc(&tIn, XSIZE*YSIZE);
float *tOut = NULL;
hipMalloc(&tOut, XSIZE*YSIZE);
float sdc = 1;
int nx = 1;
int ny = 1;
int nz = 1;
float ce = 1;
float cw = 1;
float cn = 1;
float cs = 1;
float ct = 1;
float cb = 1;
float cc = 1;
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
hotspotOpt1<<<gridBlock,threadBlock>>>(p,tIn,tOut,sdc,nx,ny,nz,ce,cw,cn,cs,ct,cb,cc);
hipDeviceSynchronize();
for (int loop_counter = 0; loop_counter < 10; ++loop_counter) {
hotspotOpt1<<<gridBlock,threadBlock>>>(p,tIn,tOut,sdc,nx,ny,nz,ce,cw,cn,cs,ct,cb,cc);
}
auto start = steady_clock::now();
for (int loop_counter = 0; loop_counter < 1000; loop_counter++) {
hotspotOpt1<<<gridBlock,threadBlock>>>(p,tIn,tOut,sdc,nx,ny,nz,ce,cw,cn,cs,ct,cb,cc);
}
auto end = steady_clock::now();
auto usecs = duration_cast<duration<float, microseconds::period> >(end - start);
cout <<'['<<usecs.count()<<','<<'('<<BLOCKX<<','<<BLOCKY<<')' << ','<<'('<<XSIZE<<','<<YSIZE<<')'<<']' << endl;
}
}}