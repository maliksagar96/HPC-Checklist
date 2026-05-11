#include <iostream>
#include <vector>
#include <ctime>
#include <cuda_runtime.h>
#include <cassert>

using namespace std;

void computeHistogram(vector<int>& input, vector<int>& histogram) {

	int size = input.size();
	int bins = histogram.size();

	for(int i = 0;i<size;i++) {
		histogram[input[i]%bins]++;
	}
}

__global__ void gpuHistogram(int *input, int *hist, int size, int bins) {
	int tid = blockIdx.x * blockDim.x + threadIdx.x;

	if(tid < size) {
		atomicAdd(&hist[input[tid]%bins], 1);		
	}
}

int main() {

	int size = 1 << 24;
	int byteSize = size * sizeof(int);
	int bins = 10;
	int binsByteSize = bins * sizeof(int);
	vector<int> input(size);
	vector<int> histogram(bins, 0);
	vector<int> gpuResult(bins, 0);

	srand(time(0));

	for(int i = 0;i < size;i++) {
		input[i] = rand() % 100;
	}

	computeHistogram(input, histogram);

	int *d_input, *d_hist;
	cudaMalloc(&d_input, byteSize); cudaMalloc(&d_hist, binsByteSize);
	cudaMemcpy(d_input, input.data(), byteSize, cudaMemcpyHostToDevice);

	int block = 256;
	int grid = (size + block - 1)/block;

	gpuHistogram<<<grid, block>>>(d_input, d_hist, size, bins);
	cudaDeviceSynchronize();
	cudaMemcpy(gpuResult.data(), d_hist, binsByteSize, cudaMemcpyDeviceToHost);

	for(int i = 0;i<bins;i++) {
		assert(gpuResult[i] == histogram[i]);
	}

	cout << "Results match.\n";

	cudaFree(d_input); cudaFree(d_hist);

	return 0;
}