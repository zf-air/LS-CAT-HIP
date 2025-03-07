#include "hip/hip_runtime.h"
#include "includes.h"
const int  Nthreads = 1024, maxFR = 100000, NrankMax = 3, nmaxiter = 500, NchanMax = 32;
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

// THIS UPDATE DOES NOT UPDATE ELOSS?
//////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////






//////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////
__global__ void	spaceFilterUpdate(const double *Params, const float *data, const float *U, const bool *UtU, const int *iC, const int *iW, float *dprod,  const int *st, const int *id, const int *counter){
volatile __shared__ float  sU[32*NrankMax];
volatile __shared__ int iU[32];
float x;
int tid, bid, ind, nt0, i, t, k, Nrank, NT, Nfilt, NchanU, Nchan;

tid 		= threadIdx.x;
bid 		= blockIdx.x;
NT      	= (int) Params[0];
Nfilt    	= (int) Params[1];
Nrank     = (int) Params[6];
NchanU    = (int) Params[10];
nt0       = (int) Params[4];
Nchan     = (int) Params[9];

// just need to do this for all filters that have overlap with id[bid] and st[id]
// tidx still represents time, from -nt0 to nt0
// tidy loops through all filters that have overlap

if (tid<NchanU)
iU[tid] = iC[tid + NchanU * iW[bid]];
__syncthreads();

if (tid<NchanU)
for (k=0;k<Nrank;k++)
sU[tid + k * NchanU] = U[iU[tid] + Nchan * bid + Nchan * Nfilt * k];

__syncthreads();

for(ind=counter[1];ind<counter[0];ind++)
if (UtU[id[ind] + Nfilt *bid]){
t = st[ind] + tid - nt0;
// if this is a hit, threads compute all time offsets
if (t>=0 & t<NT){
for (k=0;k<Nrank;k++){
x = 0.0f;
for(i=0;i<NchanU;i++)
x  += sU[i + NchanU*k] * data[t + NT * iU[i]];
dprod[t + NT*bid + k*NT*Nfilt]   = x;
}
}
}
}