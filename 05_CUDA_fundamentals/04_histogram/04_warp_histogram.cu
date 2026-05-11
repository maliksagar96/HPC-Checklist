/*
	Now the key idea is that we need work on the warp level. Till now we were working on the block level and if we reduce the scale to the warp level we'll achieve more efficiency.
*/

#include <iostream>
#include <vector>
#include <ctime>
#include <cuda_runtime.h>
#include <cassert>

using namespace std;

void computeHistogram(vector<int>& input, vector<int>& histogram) {
	int size = input.size();
	int bins = histogram.size();

	for(int i = 0; i < size; i++)
		histogram[input[i] % bins]++;
}

__global__ void gpuHistogram(int *input, int *hist, int size, int bins) {

	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	int tx = threadIdx.x;

	extern __shared__ int shmem[];

	//warpSize = 32, internal variable
	int laneId = tx % warpSize;
	int warpId = tx / warpSize;

	int warpsPerBlock = blockDim.x / warpSize;
	int *warpHist = &shmem[warpId * bins];

	//0th thread of every warp will initialize the 0th histogram element to 0 and so on. 
	for(int i = laneId;i<bins;i+=warpSize) {
		warpHist[i] = 0;
	}
	__syncthreads();

	if(tid < size) {
		atomicAdd(&warpHist[input[tid]%bins], 1);
	}
	__syncthreads();

	//0th warp will add all the warp histograms
	if(warpId == 0) {
		for(int bin = laneId;bin < bins;bin += warpSize) {
			int sum = 0;
			for(int w = 0;w<warpsPerBlock;w++) {
				sum += shmem[w * bins + bin];
			}
			atomicAdd(&hist[bin], sum);
		}		
		__syncthreads();
	}
}

int main() {

	int size = 1 << 24;
	int bins = 10;

	int byteSize = size * sizeof(int);
	int binsByteSize = bins * sizeof(int);

	vector<int> input(size);
	vector<int> cpuHist(bins, 0);
	vector<int> gpuHist(bins, 0);

	srand(time(0));

	for(int i = 0; i < size; i++)
		input[i] = rand() % 100;

	computeHistogram(input, cpuHist);

	int *d_input, *d_hist;

	cudaMalloc(&d_input, byteSize);
	cudaMalloc(&d_hist, binsByteSize);

	cudaMemcpy(d_input, input.data(), byteSize, cudaMemcpyHostToDevice);
	cudaMemset(d_hist, 0, binsByteSize);

	int block = 256;
	int grid = (size + block - 1) / block;
	int warpsPerBlock = block / 32;
	gpuHistogram<<<grid, block, warpsPerBlock * bins * sizeof(int)>>>(d_input, d_hist, size, bins);

	cudaDeviceSynchronize();
	cudaMemcpy(gpuHist.data(), d_hist, binsByteSize, cudaMemcpyDeviceToHost);

	for(int i = 0; i < bins; i++)
		assert(cpuHist[i] == gpuHist[i]);

	cout << "Results match.\n";

	cudaFree(d_input);
	cudaFree(d_hist);

	return 0;
}