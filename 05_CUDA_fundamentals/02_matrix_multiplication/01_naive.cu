#include <iostream>
#include <cuda_runtime.h>
#include <vector>
#include <cassert>

using namespace std;

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

__global__ void gpu_implementation(int *a, int *b, int *c, int P, int Q, int R) {

	int i = blockIdx.y * blockDim.y + threadIdx.y;
	int j =  blockIdx.x * blockDim.x + threadIdx.x;

	if(i < P && j < R) {
		int sum = 0;
		for(int k = 0;k<Q;k++) {
			sum += a[Q*i + k] * b[R*k + j];
		}
		c[i*R + j] = sum;
	}

}

int main() {

	int P = 128;
	int Q = 128;
	int R = 128;

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