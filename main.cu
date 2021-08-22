#include "inttypes.h"
#include "global.h"
#include "helper.h"

int main (int argc, char * argv[]) 
{
    // Inputs
    uint32_t numIterations = 1000;
    uint32_t N = 100;

    // Define solution
    uint32_t Ndofs = N*N;
    float *du0 = new float[Ndofs];
    float *du1 = new float[Ndofs];
    initializeToZeros(du0, Ndofs);
    initializeToZeros(du1, Ndofs);
    float *du0_d;
    float *du1_d;
    cudaMalloc(&du0_d, sizeof(float) * Ndofs);
    cudaMalloc(&du1_d, sizeof(float) * Ndofs);
    cudaMemcpy(du0_d, du0, sizeof(float) * Ndofs, cudaMemcpyHostToDevice);
    cudaMemcpy(du1_d, du1, sizeof(float) * Ndofs, cudaMemcpyHostToDevice);
 
    // Define rhs
    float *rhs = new float[Ndofs];
    initializeToOnes(rhs, Ndofs);
    float *rhs_d;
    cudaMalloc(&rhs_d, sizeof(float) * Ndofs);
    cudaMemcpy(rhs_d, rhs, sizeof(float) * Ndofs, cudaMemcpyHostToDevice);

    // Perform iterations in global memory
    globalMemorySolve2D(du1_d, du0_d, N, numIterations); 

    // Perform iterations in shared memory using swept
    // sharedMemorySolve(); 

    // Print out timings

}
