#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <hiprand_kernel.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <sys/time.h>
#include "stdp_kernel.cu"
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
float *weight = NULL;
hipMalloc(&weight, XSIZE*YSIZE);
int weight_size_0 = XSIZE*YSIZE;
int weight_size_1 = XSIZE*YSIZE;
int weight_size_2 = XSIZE*YSIZE;
int weight_size_3 = XSIZE*YSIZE;
float *output_spike = NULL;
hipMalloc(&output_spike, XSIZE*YSIZE);
int output_spike_size_0 = XSIZE*YSIZE;
int output_spike_size_1 = XSIZE*YSIZE;
int output_spike_size_2 = XSIZE*YSIZE;
int output_spike_size_3 = XSIZE*YSIZE;
float *history = NULL;
hipMalloc(&history, XSIZE*YSIZE);
float *weight_update = NULL;
hipMalloc(&weight_update, XSIZE*YSIZE);
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
stdp_kernel<<<gridBlock,threadBlock>>>(weight,weight_size_0,weight_size_1,weight_size_2,weight_size_3,output_spike,output_spike_size_0,output_spike_size_1,output_spike_size_2,output_spike_size_3,history,weight_update);
hipDeviceSynchronize();
for (int loop_counter = 0; loop_counter < 10; ++loop_counter) {
stdp_kernel<<<gridBlock,threadBlock>>>(weight,weight_size_0,weight_size_1,weight_size_2,weight_size_3,output_spike,output_spike_size_0,output_spike_size_1,output_spike_size_2,output_spike_size_3,history,weight_update);
}
auto start = steady_clock::now();
for (int loop_counter = 0; loop_counter < 1000; loop_counter++) {
stdp_kernel<<<gridBlock,threadBlock>>>(weight,weight_size_0,weight_size_1,weight_size_2,weight_size_3,output_spike,output_spike_size_0,output_spike_size_1,output_spike_size_2,output_spike_size_3,history,weight_update);
}
auto end = steady_clock::now();
auto usecs = duration_cast<duration<float, microseconds::period> >(end - start);
cout <<'['<<usecs.count()<<','<<'('<<BLOCKX<<','<<BLOCKY<<')' << ','<<'('<<XSIZE<<','<<YSIZE<<')'<<']' << endl;
}
}}