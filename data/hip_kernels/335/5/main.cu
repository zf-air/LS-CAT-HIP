#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <hiprand_kernel.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <sys/time.h>
#include "conductance_update_synaptic_conductances_kernel.cu"
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
float timestep = 1;
float *d_synaptic_conductances_g = NULL;
hipMalloc(&d_synaptic_conductances_g, XSIZE*YSIZE);
float *d_synaptic_efficacies_or_weights = NULL;
hipMalloc(&d_synaptic_efficacies_or_weights, XSIZE*YSIZE);
float *d_time_of_last_spike_to_reach_synapse = NULL;
hipMalloc(&d_time_of_last_spike_to_reach_synapse, XSIZE*YSIZE);
float *d_biological_conductance_scaling_constants_lambda = NULL;
hipMalloc(&d_biological_conductance_scaling_constants_lambda, XSIZE*YSIZE);
int total_number_of_synapses = 1;
float current_time_in_seconds = 1;
float *d_decay_terms_tau_g = NULL;
hipMalloc(&d_decay_terms_tau_g, XSIZE*YSIZE);
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
conductance_update_synaptic_conductances_kernel<<<gridBlock,threadBlock>>>(timestep,d_synaptic_conductances_g,d_synaptic_efficacies_or_weights,d_time_of_last_spike_to_reach_synapse,d_biological_conductance_scaling_constants_lambda,total_number_of_synapses,current_time_in_seconds,d_decay_terms_tau_g);
hipDeviceSynchronize();
for (int loop_counter = 0; loop_counter < 10; ++loop_counter) {
conductance_update_synaptic_conductances_kernel<<<gridBlock,threadBlock>>>(timestep,d_synaptic_conductances_g,d_synaptic_efficacies_or_weights,d_time_of_last_spike_to_reach_synapse,d_biological_conductance_scaling_constants_lambda,total_number_of_synapses,current_time_in_seconds,d_decay_terms_tau_g);
}
auto start = steady_clock::now();
for (int loop_counter = 0; loop_counter < 1000; loop_counter++) {
conductance_update_synaptic_conductances_kernel<<<gridBlock,threadBlock>>>(timestep,d_synaptic_conductances_g,d_synaptic_efficacies_or_weights,d_time_of_last_spike_to_reach_synapse,d_biological_conductance_scaling_constants_lambda,total_number_of_synapses,current_time_in_seconds,d_decay_terms_tau_g);
}
auto end = steady_clock::now();
auto usecs = duration_cast<duration<float, microseconds::period> >(end - start);
cout <<'['<<usecs.count()<<','<<'('<<BLOCKX<<','<<BLOCKY<<')' << ','<<'('<<XSIZE<<','<<YSIZE<<')'<<']' << endl;
}
}}