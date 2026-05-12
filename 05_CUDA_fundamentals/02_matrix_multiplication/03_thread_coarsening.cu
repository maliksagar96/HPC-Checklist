/*
	ncu --metrics l1tex__data_bank_conflicts_pipe_lsu_mem_shared_op_ld.sum,l1tex__data_bank_conflicts_pipe_lsu_mem_shared_op_st.sum ./02_shared_memory
	Now the key idea is to increase the size of A to 4 times as before. 

	ncu --metrics gpu__time_duration.sum ./03_thread_coarsening

	Que - 

*/

#include <iostream>
#include <cuda_runtime.h>
#include <vector>
#include <cassert>

using namespace std;

#define TILE 16
#define COARSE_FACTOR 4

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

//A is PxQ and B is QxR
__global__ void gpu_implementation(int *a, int *b, int *c, int P, int Q, int R) {

	//i is used for finding the correct row number of the matrix A.
	int global_row = blockIdx.y * blockDim.y * COARSE_FACTOR + threadIdx.y;

	//j is used to tell the correct column number of matrix B.
	int global_column =  blockIdx.x * blockDim.x + threadIdx.x;


	int tx = threadIdx.x;
	int ty = threadIdx.y;

	__shared__ int shmem_A[TILE * COARSE_FACTOR][TILE];
	__shared__ int shmem_B[TILE][TILE];

	int sum[COARSE_FACTOR] = {0};

	for(int tile = 0;tile < (Q + TILE - 1)/TILE;tile++) {
		
		//load elements in A. Each thread should load multiple elements of A unlike B. 

		for(int current_row = 0;current_row < COARSE_FACTOR;current_row++) {
			int fetching_row = global_row + current_row*TILE;

			if(fetching_row < P && (TILE * tile + tx) < Q)
				shmem_A[ty + current_row * TILE][tx] = a[fetching_row * Q + (TILE * tile  + tx)];
			else 
				shmem_A[ty + current_row * TILE][tx] = 0;
		}
		
		//load shared memory in of matrix B
		if(global_column < R && (TILE * tile + ty) < Q)
			shmem_B[ty][tx] = b[(TILE*tile + ty)*R + global_column];
		else 
			shmem_B[ty][tx] = 0;
			
		__syncthreads();

		
		for(int k = 0;k<TILE;k++) {
			//fetch the column of matrix B
			int b_column_element = shmem_B[k][tx];
			for(int current_row = 0;current_row < COARSE_FACTOR;current_row++) {				
				sum[current_row] += shmem_A[ty + current_row * TILE][k] * b_column_element;
			}
		}
		__syncthreads();
		
	}

	//Store results

	for(int current_row = 0;current_row < COARSE_FACTOR; current_row++) {

		int store_row = global_row + current_row * TILE;
		if(store_row < P && global_column < R) {
			c[store_row * R + global_column] = sum[current_row];
		}	
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
dim3 grid((R + block - 1)/block,(P + block * COARSE_FACTOR - 1)/(block * COARSE_FACTOR));

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