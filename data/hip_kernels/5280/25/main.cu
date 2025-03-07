#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <hiprand_kernel.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <sys/time.h>
#include "sort_boxes_by_indexes_kernel.cu"
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
float *filtered_box = NULL;
hipMalloc(&filtered_box, XSIZE*YSIZE);
int *filtered_label = NULL;
hipMalloc(&filtered_label, XSIZE*YSIZE);
int *filtered_dir = NULL;
hipMalloc(&filtered_dir, XSIZE*YSIZE);
float *box_for_nms = NULL;
hipMalloc(&box_for_nms, XSIZE*YSIZE);
int *indexes = NULL;
hipMalloc(&indexes, XSIZE*YSIZE);
int filter_count = 2;
float *sorted_filtered_boxes = NULL;
hipMalloc(&sorted_filtered_boxes, XSIZE*YSIZE);
int *sorted_filtered_label = NULL;
hipMalloc(&sorted_filtered_label, XSIZE*YSIZE);
int *sorted_filtered_dir = NULL;
hipMalloc(&sorted_filtered_dir, XSIZE*YSIZE);
float *sorted_box_for_nms = NULL;
hipMalloc(&sorted_box_for_nms, XSIZE*YSIZE);
const int num_box_corners = 1;
const int num_output_box_feature = 1;
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
sort_boxes_by_indexes_kernel<<<gridBlock,threadBlock>>>(filtered_box,filtered_label,filtered_dir,box_for_nms,indexes,filter_count,sorted_filtered_boxes,sorted_filtered_label,sorted_filtered_dir,sorted_box_for_nms,num_box_corners,num_output_box_feature);
hipDeviceSynchronize();
for (int loop_counter = 0; loop_counter < 10; ++loop_counter) {
sort_boxes_by_indexes_kernel<<<gridBlock,threadBlock>>>(filtered_box,filtered_label,filtered_dir,box_for_nms,indexes,filter_count,sorted_filtered_boxes,sorted_filtered_label,sorted_filtered_dir,sorted_box_for_nms,num_box_corners,num_output_box_feature);
}
auto start = steady_clock::now();
for (int loop_counter = 0; loop_counter < 1000; loop_counter++) {
sort_boxes_by_indexes_kernel<<<gridBlock,threadBlock>>>(filtered_box,filtered_label,filtered_dir,box_for_nms,indexes,filter_count,sorted_filtered_boxes,sorted_filtered_label,sorted_filtered_dir,sorted_box_for_nms,num_box_corners,num_output_box_feature);
}
auto end = steady_clock::now();
auto usecs = duration_cast<duration<float, microseconds::period> >(end - start);
cout <<'['<<usecs.count()<<','<<'('<<BLOCKX<<','<<BLOCKY<<')' << ','<<'('<<XSIZE<<','<<YSIZE<<')'<<']' << endl;
}
}}