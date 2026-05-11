/*
ncu --metrics l1tex__data_bank_conflicts_pipe_lsu_mem_shared_op_ld.sum,l1tex__data_bank_conflicts_pipe_lsu_mem_shared_op_st.sum ./02_shared_memory

ncu --metrics gpu__time_duration.sum ./02_shared_memory

*/

#include <iostream>
#include <cuda_runtime.h>
#include <vector>
#include <cassert>

using namespace std;

#define TILE 16

void cpu_implementation(vector<int> &matA, vector<int> &matB, vector<int> &matC, int P, int Q, int R) {

	//A is PxQ and B is QxR
	for(int i = 0;i<P;i++) {
		for(int j = 0;j<R;j++) {            
			for(int k = 0;k < Q;k++) {
				//cij = aik*bkj
				matC[i * R + j] += matA[Q*i + k] * matB[R * k + j]; 
			}
		}
	}
}

/*
The key idea is that the first block will compute the first (BLOCK) number of rows * first (BLOCK) number of columns multiplication. 
We have to slide tiles from left to right for A and top to bottom for B.
*/

__global__ void gpu_implementation(int *a, int *b, int *c, int P, int Q, int R) {
	
	//i is used for finding the correct row number of the matrix A.
	int i = blockIdx.y * blockDim.y + threadIdx.y;

	//j is used to tell the correct column number of matrix B.
	int j =  blockIdx.x * blockDim.x + threadIdx.x;

	int tx = threadIdx.x;
	int ty = threadIdx.y;

	__shared__ int shmem_A[TILE][TILE];
	__shared__ int shmem_B[TILE][TILE];

	int sum = 0;

	//load gloabl memory into the shared memory
	//Sliding tile
	for(int tile = 0;tile < (Q + TILE - 1)/TILE;tile++) {
		if(i < P && (TILE * tile + tx < Q))		
			//i tells the row number. i*Q put the index according to row major format. TILE*tile is the tile stride in column direction. Then in the tile ty tells the number of column. 
			shmem_A[ty][tx] = a[(TILE * tile) + tx + i*Q];
		else 
			shmem_A[ty][tx] = 0;
		
		//We need to do row stride.TILE * tile * R puts us at the right row number. Now ty is the row number of that tile. Hence (TILE * tile + ty)*R. Now the column j. 
		if(j < R && (TILE * tile + ty < Q))
			shmem_B[ty][tx] = b[(TILE * tile + ty) * R + j];
		else 
			shmem_B[ty][tx] = 0;

		__syncthreads();

		//Now there are only 2 tiles. We calculate the partial sum of these 2 tiles and move to the next tile. Observe that the blockID remains same. 
		for(int k = 0;k<TILE;k++) {
			//cij = aik*bkj
			//For a pair (ty,tx) the columns of A are changing and hence we are fetching a row of shared memory A. And column of the shared memory B. 
			sum += shmem_A[ty][k] * shmem_B[k][tx];
		}

		__syncthreads();
	}

	if(i < P && j < R) {
		c[i * R + j] = sum;
	}	
}

int main() {

	int P = 2048;
	int Q = 2048;
	int R = 2048;

	vector<int> matA(P*Q);
	vector<int> matB(Q*R);
	vector<int> matC(P*R, 0);
	vector<int> gpuResult(P*R);

	srand(time(0));

	for(int i = 0;i<P*Q;i++) {
		matA[i] = rand()%1000;
	}

	for(int i = 0;i<Q*R;i++) {
		matB[i] = rand()%1000;
	}

	cpu_implementation(matA, matB, matC, P, Q, R);

	int *d_a, *d_b, *d_c;

	//Allocate memory on GPU
	cudaMalloc((void**)&d_a, P * Q * sizeof(int));
	cudaMalloc((void**)&d_b, Q * R * sizeof(int));
	cudaMalloc((void**)&d_c, P * R * sizeof(int));

	//Copy data from CPU to GPU
	cudaMemcpy(d_a, matA.data(), P * Q * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, matB.data(), Q * R * sizeof(int), cudaMemcpyHostToDevice);

	//Block and Grid dimensions
	int block = 16;
	dim3 BLOCK(block, block);
	dim3 grid((P + block - 1)/block, (R + block - 1)/block);

	//Kernel launch
	gpu_implementation<<<grid, BLOCK>>>(d_a, d_b, d_c, P, Q, R);

	//Copy result back to CPU
	cudaMemcpy(gpuResult.data(), d_c, P * R * sizeof(int), cudaMemcpyDeviceToHost);

	for(int i=0;i<matC.size();i++) {
		assert(gpuResult[i] == matC[i]);
	}

	cout << "Results match.\n";

	//Free GPU memory
	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);

	return 0;
}