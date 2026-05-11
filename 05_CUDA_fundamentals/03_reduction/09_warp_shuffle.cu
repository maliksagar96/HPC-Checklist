#include <iostream>
#include <vector>
#include <ctime>
#include <cassert>
#include <cuda_runtime.h>

using namespace std;

int arraySum(vector<int>& nums) {

	cout << "Naive array Sum.\n";
	int sum = 0;
	for(int x : nums) {
		sum += x;
	}
	return sum;
}

int arrayReduction(vector<int>& nums) {

	cout << "Reduction sum.\n";
	int size = nums.size();
	for(int stride = 1; stride < size; stride *= 2) {
		for(int i = 0; i + stride < size; i += 2 * stride) {
			nums[i] = nums[i] + nums[i + stride];
		}
	}

	return nums[0];
}

__device__ int warpReduce(int sum) {

}

__global__ void reduction_shmem(int *input, int *output, int size) {

	extern __shared__ int partial_sum[];
	//int tid = blockIdx.x * blockDim.x + threadIdx.x;
	int tx = threadIdx.x;
	int tid2 = blockIdx.x * blockDim.x * 2 + tx;

	int sum = 0;
	if(tid2 < size) {
		sum = input[tid2];
	}

	if(tid2 + blockDim.x < size) {
		sum += input[tid2 + blockDim.x] ;
	}

	partial_sum[tx] = sum;
	__syncthreads();

	for(int stride = blockDim.x/2; stride > 32; stride /= 2) {	

		if(tx < stride) {
			partial_sum[tx] += partial_sum[tx + stride];
		}

		__syncthreads();
	}

    if(tx < 32) {
        warpReduce(partial_sum, threadIdx.x);
    }

	if(tx == 0) {
		output[blockIdx.x] = partial_sum[0];
	}
}

int main() {

	int size = 1 << 24;
	int byteSize = size * sizeof(int);

	vector<int> nums(size, 0);

	srand(time(0));

	for(int i = 0; i < size; i++) {
		nums[i] = rand() % 1000;
	}

	int cpuSum = arraySum(nums);
	int block = 1024;
	//Launching half the number of threads as before

	int *d_input;
	int *d_output;

	cudaMalloc(&d_input, byteSize);
	cudaMemcpy(d_input, nums.data(), byteSize, cudaMemcpyHostToDevice);

	int currentSize = size;

	while(currentSize > 1) {
		int grid = (currentSize + block - 1)/block;
		cudaMalloc(&d_output, grid * sizeof(int));		
		reduction_shmem<<<grid, block, block * sizeof(int)>>>(d_input, d_output, currentSize);
		cudaDeviceSynchronize();	
		cudaFree(d_input);
		d_input = d_output;
		currentSize = grid;
	}

	int gpuResult;

	cudaMemcpy(&gpuResult, d_output, sizeof(int), cudaMemcpyDeviceToHost);
	assert(cpuSum == gpuResult);
	
	cout << "Results Match.\n";
	cudaFree(d_input);	cudaFree(d_output);

	return 0;
}