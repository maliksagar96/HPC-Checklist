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

__global__ void reduction_shmem(int *input, int *output) {

	extern __shared__ int partial_sum[];
	int tid = blockIdx.x * blockDim.x + threadIdx.x;
	partial_sum[threadIdx.x] = input[tid];
	__syncthreads();

	for(int stride = blockDim.x/2; stride >= 1; stride /= 2) {	

		if(threadIdx.x < stride) {
			partial_sum[threadIdx.x] += partial_sum[threadIdx.x + stride];
		}

		__syncthreads();
	}

	if(threadIdx.x == 0) {
		output[blockIdx.x] = partial_sum[0];
	}
}

int main() {

	int size = 1 << 16;
	int byteSize = size * sizeof(int);

	vector<int> nums(size, 0);

	srand(time(0));

	for(int i = 0; i < size; i++) {
		nums[i] = rand() % 1000;
	}

	int cpuSum = arraySum(nums);
	int block = 256;
	int grid = (size + block - 1) / block;
	int *d_nums;
	int *d_nums_r;

	cudaMalloc(&d_nums, byteSize);
	cudaMalloc(&d_nums_r, grid * sizeof(int));
	cudaMemcpy(d_nums, nums.data(), byteSize, cudaMemcpyHostToDevice);

	reduction_shmem<<<grid, block, block * sizeof(int)>>>(d_nums, d_nums_r);
	cudaDeviceSynchronize();
	reduction_shmem<<<1, block, block * sizeof(int)>>>(d_nums_r, d_nums_r);
	cudaDeviceSynchronize();

	int gpuResult;

	cudaMemcpy(&gpuResult, d_nums_r, sizeof(int), cudaMemcpyDeviceToHost);
	assert(cpuSum == gpuResult);
	
	cout << "Results Match.\n";
	cudaFree(d_nums);
	cudaFree(d_nums_r);

	return 0;
}