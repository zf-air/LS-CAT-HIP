#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <hiprand_kernel.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <sys/time.h>
#include "disp_absolute_residual_scalable_GPU.cu"
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
float *d_abs_res = NULL;
hipMalloc(&d_abs_res, XSIZE*YSIZE);
const float *d_disparity_compact = NULL;
hipMalloc(&d_disparity_compact, XSIZE*YSIZE);
const float4 *d_Zbuffer_normals_compact = NULL;
hipMalloc(&d_Zbuffer_normals_compact, XSIZE*YSIZE);
const int *d_ind_disparity_Zbuffer = NULL;
hipMalloc(&d_ind_disparity_Zbuffer, XSIZE*YSIZE);
const unsigned int *d_valid_disparity_Zbuffer = NULL;
hipMalloc(&d_valid_disparity_Zbuffer, XSIZE*YSIZE);
float fx = 1;
float fy = 1;
float ox = 1;
float oy = 1;
float b = 2;
int n_cols = 1;
int n_valid_disparity_Zbuffer = 1;
const int *d_offset_ind = NULL;
hipMalloc(&d_offset_ind, XSIZE*YSIZE);
const int *d_segment_translation_table = NULL;
hipMalloc(&d_segment_translation_table, XSIZE*YSIZE);
float w_disp = 1;
const float *d_dTR = NULL;
hipMalloc(&d_dTR, XSIZE*YSIZE);
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
disp_absolute_residual_scalable_GPU<<<gridBlock,threadBlock>>>(d_abs_res,d_disparity_compact,d_Zbuffer_normals_compact,d_ind_disparity_Zbuffer,d_valid_disparity_Zbuffer,fx,fy,ox,oy,b,n_cols,n_valid_disparity_Zbuffer,d_offset_ind,d_segment_translation_table,w_disp,d_dTR);
hipDeviceSynchronize();
for (int loop_counter = 0; loop_counter < 10; ++loop_counter) {
disp_absolute_residual_scalable_GPU<<<gridBlock,threadBlock>>>(d_abs_res,d_disparity_compact,d_Zbuffer_normals_compact,d_ind_disparity_Zbuffer,d_valid_disparity_Zbuffer,fx,fy,ox,oy,b,n_cols,n_valid_disparity_Zbuffer,d_offset_ind,d_segment_translation_table,w_disp,d_dTR);
}
auto start = steady_clock::now();
for (int loop_counter = 0; loop_counter < 1000; loop_counter++) {
disp_absolute_residual_scalable_GPU<<<gridBlock,threadBlock>>>(d_abs_res,d_disparity_compact,d_Zbuffer_normals_compact,d_ind_disparity_Zbuffer,d_valid_disparity_Zbuffer,fx,fy,ox,oy,b,n_cols,n_valid_disparity_Zbuffer,d_offset_ind,d_segment_translation_table,w_disp,d_dTR);
}
auto end = steady_clock::now();
auto usecs = duration_cast<duration<float, microseconds::period> >(end - start);
cout <<'['<<usecs.count()<<','<<'('<<BLOCKX<<','<<BLOCKY<<')' << ','<<'('<<XSIZE<<','<<YSIZE<<')'<<']' << endl;
}
}}