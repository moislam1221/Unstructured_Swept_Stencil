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
