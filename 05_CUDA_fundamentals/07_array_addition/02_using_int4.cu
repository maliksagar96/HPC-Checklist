/*
To compile
nvcc -O3 -arch=sm_75 --generate-line-info -Xptxas -v 01_naive_array_addtion.cu -o 01_naive_array_addtion

1) Nsight compute output - 
Register per thread - 12
shmem used - 0
Memory throughput - 92.89%
Compute throughout - 15.7%
Theoretical Occupancy - 100 %
Occupency - 91 %
Aithematic intensity - 0.49
Flops - 0.78 * 10^11 Flops = .078 GLOPs.
Kernel execution time - 
L1 cache througput - 20.37
L2 cache throughput - 43.45

*/

#include <iostream>
#include <ctime>
#include <cassert>
#include <cuda_runtime.h>
#include <vector>

using namespace std;

__global__ void arrayAdd(int4 *a, int4 *b, int4 *c, int N) {

	int tid = blockIdx.x* blockDim.x + threadIdx.x;

	if(tid < N) {

		int4 a_local = a[tid];
		int4 b_local = b[tid];

		int4 c_local;

		c_local.x = a_local.x + b_local.x;
		c_local.y = a_local.y + b_local.y;
		c_local.z = a_local.z + b_local.z;
		c_local.w = a_local.w + b_local.w;

		c[tid] = c_local;
	}
}

int main() {

	int N = 1 << 24;
	int byteSize = N * sizeof(int);

	int block = 256;
	int grid = (N + 4 * block - 1)/(4 * block);

	srand(time(0));
	vector<int> h_a(N), h_b(N), h_c(N), gpuResult(N);

	for(int i = 0;i<N;i++) {
		h_a[i] = rand()%1000;
		h_b[i] = rand()%1000;
		h_c[i] = h_a[i] + h_b[i];
	}

	int *d_a, *d_b, *d_c;

	cudaMalloc(&d_a, byteSize);
	cudaMalloc(&d_b, byteSize);
	cudaMalloc(&d_c, byteSize);

	cudaMemcpy(d_a, h_a.data(), byteSize, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, h_b.data(), byteSize, cudaMemcpyHostToDevice);
	cudaMemcpy(d_c, h_c.data(), byteSize, cudaMemcpyHostToDevice);

	int4 *d_a4 = reinterpret_cast<int4*>(d_a);
	int4 *d_b4 = reinterpret_cast<int4*>(d_b);
	int4 *d_c4 = reinterpret_cast<int4*>(d_c);

	arrayAdd<<<grid, block>>>(d_a4, d_b4, d_c4, N/4);
	cudaMemcpy(gpuResult.data(), d_c, byteSize, cudaMemcpyDeviceToHost);

	for(int i = 0;i<N;i++) {
		assert(gpuResult[i] == h_c[i]);
	}

	cout << "Results match.\n";

	cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
	return 0;
}