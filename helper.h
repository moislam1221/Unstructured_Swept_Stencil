void initializeToMaxInt(uint32_t * du, uint32_t Ndofs) 
{
    for (int i = 0; i < Ndofs; i++) {
        du[i] = UINT32_MAX;
    }
}


void initializeToZerosInt(uint32_t * du, uint32_t Ndofs) 
{
    for (int i = 0; i < Ndofs; i++) {
        du[i] = 0;
    }
}

void initializeToZeros(float * du, uint32_t Ndofs) 
{
    for (int i = 0; i < Ndofs; i++) {
        du[i] = 0.0;
    }
}

void initializeToOnes(float * du, uint32_t Ndofs) 
{
    for (int i = 0; i < Ndofs; i++) {
        du[i] = 0.0;
    }
}


void construct2DConnectivity(uint32_t * idxPtr, uint32_t * nodeNeighbors, uint32_t N)
{
    idxPtr[0] = 0;
    int idx = 0;
    uint32_t dof, leftDOF, rightDOF, topDOF, bottomDOF;
    uint32_t idxPtrShift = 0;
    
    // Loop over the grid
    for (int iy = 0; iy < N; iy++) {
        for (int ix = 0; ix < N; ix++) {
            // Identify the center DOF
            dof = ix + iy * N;
            // Identify the neighbor DOFs
            leftDOF = dof - 1;
            rightDOF = dof + 1;
            topDOF = dof + N;
            bottomDOF = dof - N;
            // Reset index Pointer shift
            idxPtrShift = 1;
            // Left
            if (ix > 0) {
                nodeNeighbors[idx] = leftDOF;
                idx += 1;
                idxPtrShift += 1;
            }
            // Right
            if (ix < N-1) {
                nodeNeighbors[idx] = rightDOF;
                idx += 1;
                idxPtrShift += 1;
            }
            // Center
            nodeNeighbors[idx] = dof;
            // Bottom
            if (iy > 0) {
                nodeNeighbors[idx] = bottomDOF;
                idx += 1;
                idxPtrShift += 1;
            }
            // Top
            if (iy > N-1) {
                nodeNeighbors[idx] = topDOF;
                idx += 1;
                idxPtrShift += 1;
            }
            // Set the idxPtr entry values
            idxPtr[dof+1] = idxPtr[dof] + idxPtrShift;
        }
    }
}


void expand(vector<set<uint32_t>> &seeds, uint32_t * subdomainOfNodes, uint32_t Ndofs, uint32_t * idxPtr, uint32_t * nodeNeighbors)
{
    uint32_t * nodesClaimedArray = new uint32_t[Ndofs];
    initializeToZerosInt(nodesClaimedArray, Ndofs);
    uint32_t numSubdomains = seeds.size();
    bool continueExpansion = true;
    uint32_t neighbor;

    for (int i = 0; i < numSubdomains; i++) {
        for (auto dof : seeds[i]) {
            subdomainOfNodes[dof] = i;
        }
    }


    while (continueExpansion == true) {
        for (int i = 0; i < numSubdomains; i++) {
            for (auto dof : seeds[i]) {
                printf("dof = %d\n", dof);
                for (int k = idxPtr[dof]; k < idxPtr[dof+1]; k++) {
		    neighbor = nodeNeighbors[k];
                    printf("Potential neighbor is %d\n", neighbor);
                    if (nodesClaimedArray[neighbor] == 0) {
                        nodesClaimedArray[neighbor] = 1;
                        subdomainOfNodes[neighbor] = i;
                        printf("Adding neighbor = %d to subdomain = %d\n", neighbor, i);
                    } 
		    else {
		        continueExpansion = false;
                    } 
                }
            }   
        }             
    }

}


