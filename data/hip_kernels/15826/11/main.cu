#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <hiprand_kernel.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <sys/time.h>
#include "compute_G_cols_kernel.cu"
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
int N_i = 1;
int N_r = 1;
int N_c = 1;
int *p_ptr = NULL;
hipMalloc(&p_ptr, XSIZE*YSIZE);
double *exp_V_ptr = NULL;
hipMalloc(&exp_V_ptr, XSIZE*YSIZE);
double *N_ptr = NULL;
hipMalloc(&N_ptr, XSIZE*YSIZE);
int N_ld = 1;
double *G_ptr = NULL;
hipMalloc(&G_ptr, XSIZE*YSIZE);
int G_ld = 1;
double *G_cols_ptr = NULL;
hipMalloc(&G_cols_ptr, XSIZE*YSIZE);
int G_cols_ld = 1;
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
compute_G_cols_kernel<<<gridBlock,threadBlock>>>(N_i,N_r,N_c,p_ptr,exp_V_ptr,N_ptr,N_ld,G_ptr,G_ld,G_cols_ptr,G_cols_ld);
hipDeviceSynchronize();
for (int loop_counter = 0; loop_counter < 10; ++loop_counter) {
compute_G_cols_kernel<<<gridBlock,threadBlock>>>(N_i,N_r,N_c,p_ptr,exp_V_ptr,N_ptr,N_ld,G_ptr,G_ld,G_cols_ptr,G_cols_ld);
}
auto start = steady_clock::now();
for (int loop_counter = 0; loop_counter < 1000; loop_counter++) {
compute_G_cols_kernel<<<gridBlock,threadBlock>>>(N_i,N_r,N_c,p_ptr,exp_V_ptr,N_ptr,N_ld,G_ptr,G_ld,G_cols_ptr,G_cols_ld);
}
auto end = steady_clock::now();
auto usecs = duration_cast<duration<float, microseconds::period> >(end - start);
cout <<'['<<usecs.count()<<','<<'('<<BLOCKX<<','<<BLOCKY<<')' << ','<<'('<<XSIZE<<','<<YSIZE<<')'<<']' << endl;
}
}}