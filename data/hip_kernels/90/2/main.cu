#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <hiprand_kernel.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <sys/time.h>
#include "convolution_backward_kernel.cu"
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
float *y_h = NULL;
hipMalloc(&y_h, XSIZE*YSIZE);
float *filters = NULL;
hipMalloc(&filters, XSIZE*YSIZE);
float *vbias = NULL;
hipMalloc(&vbias, XSIZE*YSIZE);
float *target = NULL;
hipMalloc(&target, XSIZE*YSIZE);
float *y_v = NULL;
hipMalloc(&y_v, XSIZE*YSIZE);
int input_size = XSIZE*YSIZE;
int lu_padding = 1;
int channel_num = 1;
int feature_map_size = XSIZE*YSIZE;
int filter_num = 2;
int filter_size = XSIZE*YSIZE;
float *rnd_array = NULL;
hipMalloc(&rnd_array, XSIZE*YSIZE);
int rnd_num = 1;
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
convolution_backward_kernel<<<gridBlock,threadBlock>>>(y_h,filters,vbias,target,y_v,input_size,lu_padding,channel_num,feature_map_size,filter_num,filter_size,rnd_array,rnd_num);
hipDeviceSynchronize();
for (int loop_counter = 0; loop_counter < 10; ++loop_counter) {
convolution_backward_kernel<<<gridBlock,threadBlock>>>(y_h,filters,vbias,target,y_v,input_size,lu_padding,channel_num,feature_map_size,filter_num,filter_size,rnd_array,rnd_num);
}
auto start = steady_clock::now();
for (int loop_counter = 0; loop_counter < 1000; loop_counter++) {
convolution_backward_kernel<<<gridBlock,threadBlock>>>(y_h,filters,vbias,target,y_v,input_size,lu_padding,channel_num,feature_map_size,filter_num,filter_size,rnd_array,rnd_num);
}
auto end = steady_clock::now();
auto usecs = duration_cast<duration<float, microseconds::period> >(end - start);
cout <<'['<<usecs.count()<<','<<'('<<BLOCKX<<','<<BLOCKY<<')' << ','<<'('<<XSIZE<<','<<YSIZE<<')'<<']' << endl;
}
}}