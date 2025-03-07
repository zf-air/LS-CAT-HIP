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
__global__ void	extractFEAT(const double *Params, const int *st, const int *id, const int *counter, const float *dout, const int *iList, const float *mu, float *d_feat){
int t, tidx, tidy,Nblocks,NthreadsX,idF, bid,  NT, ind, tcurr, Nnearest;
float rMax, Ci, Cf, lam;
tidx 		= threadIdx.x;
tidy 		= threadIdx.y;

bid 		= blockIdx.x;
NT 		= (int) Params[0];
Nnearest 	= (int) Params[5];
NthreadsX 	= blockDim.x;
Nblocks               = gridDim.x;
lam 	    = (float) Params[7];

// each thread x does a nearby filter
// each thread x combines with blocks to go through all new spikes
ind = counter[1]+tidx + NthreadsX * bid;

while(ind<counter[0]){
tcurr = st[ind];
rMax = 0.0f;
idF = iList[tidy + Nnearest * id[ind]];

for (t=-3;t<3;t++){
Ci = dout[tcurr +t+ idF * NT] + lam/mu[idF];
Cf = Ci / sqrt(lam/(mu[idF] * mu[idF]) + 1.0f);
rMax = max(rMax, Cf);
}
d_feat[tidy + ind * Nnearest] = rMax;
ind += NthreadsX * Nblocks;
}
}