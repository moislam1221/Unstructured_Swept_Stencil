using namespace std; 

#include "inttypes.h"
#include "global.h"
#include <vector>
#include <set>
#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include "helper.h"

int main (int argc, char * argv[]) 
{
    // Inputs
    uint32_t numIterations = 1;
    uint32_t N = 10;

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

    /* */
    
    // Create the idxPtr and nodeNeighbors for 2D Structured
    uint32_t numEntries = (N-1)*(N-1)*5 + 4*(N-2)*4 + 4*3;
    uint32_t * idxPtr = new uint32_t[Ndofs+1];
    uint32_t * nodeNeighbors = new uint32_t[numEntries];
    construct2DConnectivity(idxPtr, nodeNeighbors, N);

    // Establish the partitioning for the first upper pyramidal stage
    vector<set<uint32_t>> arrayOfSeeds;
    set<uint32_t> seeds;
    // Fill up seeds
    // Seed 1
    seeds.insert(0);
    arrayOfSeeds.push_back(seeds);
    // Seed 2
    seeds.clear();
    seeds.insert(N);
    arrayOfSeeds.push_back(seeds);
    // Seed 3
    seeds.clear();
    seeds.insert(N*N-N);
    arrayOfSeeds.push_back(seeds);
    // Seed 4
    seeds.clear();
    seeds.insert(N*N-1);
    arrayOfSeeds.push_back(seeds);
 
    // Expand the seeds into the territories 
    uint32_t * subdomainOfNodes = new uint32_t[Ndofs];
    initializeToMaxInt(subdomainOfNodes, Ndofs);
    expand(arrayOfSeeds, subdomainOfNodes, Ndofs, idxPtr, nodeNeighbors);
    for (int i = 0; i < Ndofs; i++) {
        printf("subdomainOfNodes[%d] = %d\n", i, subdomainOfNodes[i]);
    }    

    // sharedMemorySolveUP<<<blocks, threadsPerBlock>>>
     

    // Perform iterations in shared memory using swept
    // sharedMemorySolve(); 

    // Print out timings

}
