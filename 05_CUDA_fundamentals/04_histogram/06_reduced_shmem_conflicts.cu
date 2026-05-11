/*
	To observe kernel execution time. 
	ncu --metrics gpu__time_duration.sum 06_reduced_shmem_conflicts

	To observe bank conflicts
	ncu --metrics l1tex__data_bank_conflicts_pipe_lsu_mem_shared.sum 06_reduced_shmem_conflicts
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

__global__ void gpuHistogram(int *input, int *hist, int size, int bins, int padding) {

	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	int tx = threadIdx.x;

	extern __shared__ int shmem[];

	int laneId = tx % warpSize;
	int warpId = tx / warpSize;

	int warpsPerBlock = blockDim.x / warpSize;

	int *warpHist = &shmem[warpId * (bins+1)];

	for(int i = laneId; i < bins; i += warpSize)
		warpHist[i] = 0;

	__syncthreads();

	for(int i = tid; i < size; i += blockDim.x * gridDim.x) {

		int bin = input[i] % bins;

		unsigned int mask = __match_any_sync(0xffffffff, bin);

		int leader = __ffs(mask) - 1;

		int count = __popc(mask);

		if(laneId == leader)
			atomicAdd(&warpHist[bin], count);
	}

	__syncthreads();

	if(warpId == 0) {

		for(int bin = laneId; bin < bins; bin += warpSize) {

			int sum = 0;

			for(int w = 0; w < warpsPerBlock; w++)
				sum += shmem[w * (bins+padding) + bin];

			atomicAdd(&hist[bin], sum);
		}
	}
}

int main() {

	int size = 1 << 24;
	int bins = 10;
	int padding = 1;

	int byteSize = size * sizeof(int);
	int binsByteSize = bins * sizeof(int);

	vector<int> input(size);
	vector<int> cpuHist(bins, 0);
	vector<int> gpuHist(bins, 0);

	srand(time(0));

	for(int i = 0; i < size; i++)
		input[i] = rand() % 1000;

	computeHistogram(input, cpuHist);

	int *d_input, *d_hist;

	cudaMalloc(&d_input, byteSize);
	cudaMalloc(&d_hist, binsByteSize);

	cudaMemcpy(d_input, input.data(), byteSize, cudaMemcpyHostToDevice);

	cudaMemset(d_hist, 0, binsByteSize);

	int block = 256;
	int grid = 256;

	int warpsPerBlock = block / 32;

	gpuHistogram<<<grid, block, warpsPerBlock * (bins + padding) * sizeof(int)>>>(d_input, d_hist, size, bins, padding);

	cudaDeviceSynchronize();

	cudaMemcpy(gpuHist.data(), d_hist, binsByteSize, cudaMemcpyDeviceToHost);

	for(int i = 0; i < bins; i++)
		assert(cpuHist[i] == gpuHist[i]);

	cout << "Results match.\n";

	cudaFree(d_input);
	cudaFree(d_hist);

	return 0;
}