#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <hiprand_kernel.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <sys/time.h>
#include "kernel_push2_atomic.cu"
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
int *g_left_weight = NULL;
hipMalloc(&g_left_weight, XSIZE*YSIZE);
int *g_right_weight = NULL;
hipMalloc(&g_right_weight, XSIZE*YSIZE);
int *g_down_weight = NULL;
hipMalloc(&g_down_weight, XSIZE*YSIZE);
int *g_up_weight = NULL;
hipMalloc(&g_up_weight, XSIZE*YSIZE);
int *g_sink_weight = NULL;
hipMalloc(&g_sink_weight, XSIZE*YSIZE);
int *g_push_reser = NULL;
hipMalloc(&g_push_reser, XSIZE*YSIZE);
int *g_pull_left = NULL;
hipMalloc(&g_pull_left, XSIZE*YSIZE);
int *g_pull_right = NULL;
hipMalloc(&g_pull_right, XSIZE*YSIZE);
int *g_pull_down = NULL;
hipMalloc(&g_pull_down, XSIZE*YSIZE);
int *g_pull_up = NULL;
hipMalloc(&g_pull_up, XSIZE*YSIZE);
int *g_relabel_mask = NULL;
hipMalloc(&g_relabel_mask, XSIZE*YSIZE);
int *g_graph_height = NULL;
hipMalloc(&g_graph_height, XSIZE*YSIZE);
int *g_height_write = NULL;
hipMalloc(&g_height_write, XSIZE*YSIZE);
int graph_size = XSIZE*YSIZE;
int width = XSIZE;
int rows = XSIZE;
int graph_size1 = XSIZE*YSIZE;
int width1 = XSIZE;
int rows1 = 1;
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
kernel_push2_atomic<<<gridBlock,threadBlock>>>(g_left_weight,g_right_weight,g_down_weight,g_up_weight,g_sink_weight,g_push_reser,g_pull_left,g_pull_right,g_pull_down,g_pull_up,g_relabel_mask,g_graph_height,g_height_write,graph_size,width,rows,graph_size1,width1,rows1);
hipDeviceSynchronize();
for (int loop_counter = 0; loop_counter < 10; ++loop_counter) {
kernel_push2_atomic<<<gridBlock,threadBlock>>>(g_left_weight,g_right_weight,g_down_weight,g_up_weight,g_sink_weight,g_push_reser,g_pull_left,g_pull_right,g_pull_down,g_pull_up,g_relabel_mask,g_graph_height,g_height_write,graph_size,width,rows,graph_size1,width1,rows1);
}
auto start = steady_clock::now();
for (int loop_counter = 0; loop_counter < 1000; loop_counter++) {
kernel_push2_atomic<<<gridBlock,threadBlock>>>(g_left_weight,g_right_weight,g_down_weight,g_up_weight,g_sink_weight,g_push_reser,g_pull_left,g_pull_right,g_pull_down,g_pull_up,g_relabel_mask,g_graph_height,g_height_write,graph_size,width,rows,graph_size1,width1,rows1);
}
auto end = steady_clock::now();
auto usecs = duration_cast<duration<float, microseconds::period> >(end - start);
cout <<'['<<usecs.count()<<','<<'('<<BLOCKX<<','<<BLOCKY<<')' << ','<<'('<<XSIZE<<','<<YSIZE<<')'<<']' << endl;
}
}}