#include "hip/hip_runtime.h"
#include "includes.h"
__global__ void __ADAGradm(int nrows, int ncols, float *mm, float *um, float *ssq, float *momentum, float mu, float *mask, int maskr, float nw, float *ve, int nve, float *ts, int nts, float *lr, int nlr, float langevin, float eps, int doupdate, hiprandState *rstates) {
int ithread = threadIdx.x + blockDim.x * (blockIdx.x + gridDim.x * blockIdx.y);
int nthreads = blockDim.x * gridDim.x * gridDim.y;
int i, irow, icol;
float mmval, umval, sqrtss, sqrtnewss, veval, tsval, lrval, denom, grad;
float sqrtnw = sqrtf(nw);
float sqrt1mnw = sqrtf(1-nw);
float sqrteps = sqrt(eps);
hiprandState *prstate = &rstates[ithread];
for (i = ithread; i < nrows*ncols; i += nthreads) {
icol = i / nrows;
irow = i - icol * nrows;
umval = um[i];
sqrtss = ssq[i];
//    newss = (nw * umval * umval) + (1 - nw) * sqval;
sqrtnewss = hypotf(sqrtnw * umval, sqrt1mnw * sqrtss);
ssq[i] = sqrtnewss;
if (doupdate) {
mmval = mm[i];
veval = (nve > 1) ? ve[irow] : ve[0];
tsval = (nts > 1) ? ts[irow] : ts[0];
lrval = (nlr > 1) ? lr[irow] : lr[0];
sqrtnewss = hypotf(sqrtnewss, sqrteps);
denom = (veval == 0.5f) ? sqrtnewss : powf(sqrtnewss, veval*2);
grad = (umval / denom);
if (langevin > 0) grad += hiprand_normal(prstate) * langevin;
grad = grad * lrval * tsval;               // Normal gradient
grad = grad + mu * momentum[i];            // Gradient with momentum
momentum[i] = grad;                        // Save it
mmval += grad;                             // Add the new gradient
if (maskr > 0) {
if (maskr > 1) {
mmval *= mask[i];
} else {
mmval *= mask[icol];
}
}
mm[i] = mmval;
}
}
}