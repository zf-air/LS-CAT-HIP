#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <hiprand_kernel.h>
#include <stdlib.h>
#include <hip/hip_runtime.h>
#include <sys/time.h>
#include "check_for_neuron_spikes_kernel.cu"
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
float *d_membrane_potentials_v = NULL;
hipMalloc(&d_membrane_potentials_v, XSIZE*YSIZE);
float *d_thresholds_for_action_potential_spikes = NULL;
hipMalloc(&d_thresholds_for_action_potential_spikes, XSIZE*YSIZE);
float *d_resting_potentials = NULL;
hipMalloc(&d_resting_potentials, XSIZE*YSIZE);
float *d_last_spike_time_of_each_neuron = NULL;
hipMalloc(&d_last_spike_time_of_each_neuron, XSIZE*YSIZE);
unsigned char *d_bitarray_of_neuron_spikes = NULL;
hipMalloc(&d_bitarray_of_neuron_spikes, XSIZE*YSIZE);
int bitarray_length = 1;
int bitarray_maximum_axonal_delay_in_timesteps = 1;
float current_time_in_seconds = 1;
float timestep = 1;
size_t total_number_of_neurons = 1;
bool high_fidelity_spike_flag = 1;
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
check_for_neuron_spikes_kernel<<<gridBlock,threadBlock>>>(d_membrane_potentials_v,d_thresholds_for_action_potential_spikes,d_resting_potentials,d_last_spike_time_of_each_neuron,d_bitarray_of_neuron_spikes,bitarray_length,bitarray_maximum_axonal_delay_in_timesteps,current_time_in_seconds,timestep,total_number_of_neurons,high_fidelity_spike_flag);
hipDeviceSynchronize();
for (int loop_counter = 0; loop_counter < 10; ++loop_counter) {
check_for_neuron_spikes_kernel<<<gridBlock,threadBlock>>>(d_membrane_potentials_v,d_thresholds_for_action_potential_spikes,d_resting_potentials,d_last_spike_time_of_each_neuron,d_bitarray_of_neuron_spikes,bitarray_length,bitarray_maximum_axonal_delay_in_timesteps,current_time_in_seconds,timestep,total_number_of_neurons,high_fidelity_spike_flag);
}
auto start = steady_clock::now();
for (int loop_counter = 0; loop_counter < 1000; loop_counter++) {
check_for_neuron_spikes_kernel<<<gridBlock,threadBlock>>>(d_membrane_potentials_v,d_thresholds_for_action_potential_spikes,d_resting_potentials,d_last_spike_time_of_each_neuron,d_bitarray_of_neuron_spikes,bitarray_length,bitarray_maximum_axonal_delay_in_timesteps,current_time_in_seconds,timestep,total_number_of_neurons,high_fidelity_spike_flag);
}
auto end = steady_clock::now();
auto usecs = duration_cast<duration<float, microseconds::period> >(end - start);
cout <<'['<<usecs.count()<<','<<'('<<BLOCKX<<','<<BLOCKY<<')' << ','<<'('<<XSIZE<<','<<YSIZE<<')'<<']' << endl;
}
}}