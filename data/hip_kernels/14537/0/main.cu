#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <hiprand_kernel.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <sys/time.h>
#include "subtract_psf_kernel.cu"
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
double *res_p_trans = NULL;
hipMalloc(&res_p_trans, XSIZE*YSIZE);
const double *psf_p_trans = NULL;
hipMalloc(&psf_p_trans, XSIZE*YSIZE);
const int stopx = 1;
const int stopy = 1;
const int diff = 1;
const int linsize = 1;
const double peak_x_gain = 1;
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
subtract_psf_kernel<<<gridBlock,threadBlock>>>(res_p_trans,psf_p_trans,stopx,stopy,diff,linsize,peak_x_gain);
hipDeviceSynchronize();
for (int loop_counter = 0; loop_counter < 10; ++loop_counter) {
subtract_psf_kernel<<<gridBlock,threadBlock>>>(res_p_trans,psf_p_trans,stopx,stopy,diff,linsize,peak_x_gain);
}
auto start = steady_clock::now();
for (int loop_counter = 0; loop_counter < 1000; loop_counter++) {
subtract_psf_kernel<<<gridBlock,threadBlock>>>(res_p_trans,psf_p_trans,stopx,stopy,diff,linsize,peak_x_gain);
}
auto end = steady_clock::now();
auto usecs = duration_cast<duration<float, microseconds::period> >(end - start);
cout <<'['<<usecs.count()<<','<<'('<<BLOCKX<<','<<BLOCKY<<')' << ','<<'('<<XSIZE<<','<<YSIZE<<')'<<']' << endl;
}
}}