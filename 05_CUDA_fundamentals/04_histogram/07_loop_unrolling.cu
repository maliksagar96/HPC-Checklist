#include <iostream>
#include <vector>
#include <ctime>
#include <cuda_runtime.h>
#include <cassert>

using namespace std;

void computeHistogram(vector<int>& input, vector<int>& histogram) {

	int size = input.size(), bins = histogram.size();

	for(int i=0;i<size;i++) histogram[input[i]%bins]++;
}

__global__ void gpuHistogram(int *input, int *hist, int size, int bins, int padding) {

	int tid = blockIdx.x * blockDim.x + threadIdx.x, tx = threadIdx.x;
	extern __shared__ int shmem[];

	int laneId = tx % warpSize, warpId = tx / warpSize;
	int warpsPerBlock = blockDim.x / warpSize;
	int stride = bins + padding;

	int *warpHist = &shmem[warpId * stride];

	for(int i=laneId;i<bins;i+=warpSize) warpHist[i] = 0;

	__syncthreads();

	int localHist0 = 0, localHist1 = 0, localHist2 = 0, localHist3 = 0;

	for(int i=tid;i<size;i+=blockDim.x * gridDim.x * 4) {

		if(i < size) {
			int bin = input[i] % bins;
			if(bin == 0) localHist0++;
			else if(bin == 1) localHist1++;
			else if(bin == 2) localHist2++;
			else if(bin == 3) localHist3++;
			else atomicAdd(&warpHist[bin], 1);
		}

		if(i + blockDim.x * gridDim.x < size) {
			int bin = input[i + blockDim.x * gridDim.x] % bins;
			if(bin == 0) localHist0++;
			else if(bin == 1) localHist1++;
			else if(bin == 2) localHist2++;
			else if(bin == 3) localHist3++;
			else atomicAdd(&warpHist[bin], 1);
		}

		if(i + 2 * blockDim.x * gridDim.x < size) {
			int bin = input[i + 2 * blockDim.x * gridDim.x] % bins;
			if(bin == 0) localHist0++;
			else if(bin == 1) localHist1++;
			else if(bin == 2) localHist2++;
			else if(bin == 3) localHist3++;
			else atomicAdd(&warpHist[bin], 1);
		}

		if(i + 3 * blockDim.x * gridDim.x < size) {
			int bin = input[i + 3 * blockDim.x * gridDim.x] % bins;
			if(bin == 0) localHist0++;
			else if(bin == 1) localHist1++;
			else if(bin == 2) localHist2++;
			else if(bin == 3) localHist3++;
			else atomicAdd(&warpHist[bin], 1);
		}
	}

	if(localHist0) atomicAdd(&warpHist[0], localHist0);
	if(localHist1) atomicAdd(&warpHist[1], localHist1);
	if(localHist2) atomicAdd(&warpHist[2], localHist2);
	if(localHist3) atomicAdd(&warpHist[3], localHist3);

	__syncthreads();

	if(warpId == 0) {

		for(int bin=laneId;bin<bins;bin+=warpSize) {

			int sum = 0;

			for(int w=0;w<warpsPerBlock;w++) sum += shmem[w * stride + bin];

			atomicAdd(&hist[bin], sum);
		}
	}
}

int main() {

	int size = 1 << 24, bins = 100, padding = 1;

	int byteSize = size * sizeof(int), binsByteSize = bins * sizeof(int);

	vector<int> input(size), cpuHist(bins, 0), gpuHist(bins, 0);

	srand(time(0));

	for(int i=0;i<size;i++) input[i] = rand() % 1000;

	computeHistogram(input, cpuHist);

	int *d_input, *d_hist;

	cudaMalloc(&d_input, byteSize); cudaMalloc(&d_hist, binsByteSize);

	cudaMemcpy(d_input, input.data(), byteSize, cudaMemcpyHostToDevice);

	cudaMemset(d_hist, 0, binsByteSize);

	int block = 256, grid = 256;

	int warpsPerBlock = block / 32;

	gpuHistogram<<<grid, block, warpsPerBlock * (bins + padding) * sizeof(int)>>>(d_input, d_hist, size, bins, padding);

	cudaDeviceSynchronize();

	cudaMemcpy(gpuHist.data(), d_hist, binsByteSize, cudaMemcpyDeviceToHost);

	for(int i=0;i<bins;i++) assert(cpuHist[i] == gpuHist[i]);

	cout << "Results match.\n";

	cudaFree(d_input); cudaFree(d_hist);

	return 0;
}