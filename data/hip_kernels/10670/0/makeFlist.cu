#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void makeFlist(unsigned int *d_trans_offset, unsigned int *d_transactions, unsigned int *d_flist, unsigned int num_transactions, unsigned int num_items_in_transactions){

__shared__ unsigned int private_items[max_unique_items];

int tx = threadIdx.x;
int index = tx + blockDim.x * blockIdx.x;
int location_x;

for (int i = 0; i < ceil(max_unique_items / (1.0 * BLOCK_SIZE)); i++){
location_x = tx + i * blockDim.x;
if ( location_x < max_unique_items)
private_items[location_x] = 0;
}

__syncthreads();

//int item_ends = 0;

// if (tx == (num_transactions - 1)){
// 	item_ends = num_items_in_transactions;
// }else{
// 	item_ends = d_trans_offset[index + 1];
// }
// //int j = 0;
// for(int i = d_trans_offset[index]; i < item_ends; i++){
// 	if (d_transactions[i] < max_unique_items)
// 		atomicAdd(&private_items[d_transactions[i]], 1);
// 	//j = d_transactions[i];
// }
if (index < num_items_in_transactions && d_transactions[index] < max_unique_items)
atomicAdd(&private_items[d_transactions[index]], 1);

__syncthreads();

for (int i = 0; i < ceil(max_unique_items / (1.0 * BLOCK_SIZE)); i++){
location_x = tx + i * blockDim.x;
if ( location_x < max_unique_items)
atomicAdd(&d_flist[location_x], private_items[location_x]);
}
__syncthreads();

}