#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <hiprand_kernel.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <sys/time.h>
#include "update_synaptic_efficacies_or_weights_kernel.cu"
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
float *d_recent_presynaptic_activities_C = NULL;
hipMalloc(&d_recent_presynaptic_activities_C, XSIZE*YSIZE);
float *d_recent_postsynaptic_activities_D = NULL;
hipMalloc(&d_recent_postsynaptic_activities_D, XSIZE*YSIZE);
int *d_postsynaptic_neuron_indices = NULL;
hipMalloc(&d_postsynaptic_neuron_indices, XSIZE*YSIZE);
float *d_synaptic_efficacies_or_weights = NULL;
hipMalloc(&d_synaptic_efficacies_or_weights, XSIZE*YSIZE);
float current_time_in_seconds = 1;
float *d_time_of_last_spike_to_reach_synapse = NULL;
hipMalloc(&d_time_of_last_spike_to_reach_synapse, XSIZE*YSIZE);
float *d_last_spike_time_of_each_neuron = NULL;
hipMalloc(&d_last_spike_time_of_each_neuron, XSIZE*YSIZE);
float learning_rate_rho = 1;
int *d_plastic_synapse_indices = NULL;
hipMalloc(&d_plastic_synapse_indices, XSIZE*YSIZE);
size_t total_number_of_plastic_synapses = 1;
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
update_synaptic_efficacies_or_weights_kernel<<<gridBlock,threadBlock>>>(d_recent_presynaptic_activities_C,d_recent_postsynaptic_activities_D,d_postsynaptic_neuron_indices,d_synaptic_efficacies_or_weights,current_time_in_seconds,d_time_of_last_spike_to_reach_synapse,d_last_spike_time_of_each_neuron,learning_rate_rho,d_plastic_synapse_indices,total_number_of_plastic_synapses);
hipDeviceSynchronize();
for (int loop_counter = 0; loop_counter < 10; ++loop_counter) {
update_synaptic_efficacies_or_weights_kernel<<<gridBlock,threadBlock>>>(d_recent_presynaptic_activities_C,d_recent_postsynaptic_activities_D,d_postsynaptic_neuron_indices,d_synaptic_efficacies_or_weights,current_time_in_seconds,d_time_of_last_spike_to_reach_synapse,d_last_spike_time_of_each_neuron,learning_rate_rho,d_plastic_synapse_indices,total_number_of_plastic_synapses);
}
auto start = steady_clock::now();
for (int loop_counter = 0; loop_counter < 1000; loop_counter++) {
update_synaptic_efficacies_or_weights_kernel<<<gridBlock,threadBlock>>>(d_recent_presynaptic_activities_C,d_recent_postsynaptic_activities_D,d_postsynaptic_neuron_indices,d_synaptic_efficacies_or_weights,current_time_in_seconds,d_time_of_last_spike_to_reach_synapse,d_last_spike_time_of_each_neuron,learning_rate_rho,d_plastic_synapse_indices,total_number_of_plastic_synapses);
}
auto end = steady_clock::now();
auto usecs = duration_cast<duration<float, microseconds::period> >(end - start);
cout <<'['<<usecs.count()<<','<<'('<<BLOCKX<<','<<BLOCKY<<')' << ','<<'('<<XSIZE<<','<<YSIZE<<')'<<']' << endl;
}
}}