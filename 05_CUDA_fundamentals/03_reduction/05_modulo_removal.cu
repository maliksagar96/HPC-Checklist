/*
	Getting rid of the modulo now. 
*/

#include <iostream>
#include <vector>
#include <ctime>
#include <cassert>
#include <cuda_runtime.h>

using namespace std;

int arraySum(vector<int>& nums) {
	cout << "Naive array Sum.\n"; 
	int sum = 0;
	for(int x:nums) {
    sum += x;
	}
	return sum;
}

/*
  Reduction algorithm. First add elements 0 and 1, 2 and 3, 4 and 5 and so on.
  Then add 0 and 2, 4 and 6 and so on. 
  Then add 0 and 4, 5 and 8 and so on. 
  And so on. 
*/

int arrayReduction(vector<int>& nums){

	cout << "Reduction sum.\n";
	int size = nums.size();
  for(int stride = 1;stride < nums.size();stride *= 2) {
    for(int i = 0;i<nums.size();i+=stride) {
      nums[i] = nums[i] + nums[i+stride];
    }
  }
  
	return nums[0];
}

/* Naive GPU reduction.*/
__global__ void gpuReduction(int *nums, int *reduced_nums, int N) {

	extern __shared__ int shmem[];
	int tx = threadIdx.x;
	int tid = blockDim.x * blockIdx.x + tx;

	if(tid < N) {
		shmem[tx] = nums[tid];
	}
	else {
		shmem[tx] = 0;
	}

	__syncthreads();

	for(int stride = blockDim.x/2; stride >=1 ; stride /= 2) {		
		if(tx < stride) {
			shmem[tx] += shmem[tx + stride];
		}
		__syncthreads();
	}

	if(tx == 0) {
		reduced_nums[blockIdx.x] = shmem[0];
	}
}

int main() {

	int N = 1 << 12;
	int byteSize = N * sizeof(int);
	int *d_nums;
	int *d_nums_reduced = nullptr;
	
	int gpuResult;

	int block = 256;
	int grid = (N + block - 1) / block;
	int reduced_byteSize = grid * sizeof(int);

	vector<int> nums(N, 0);

	srand(time(0));
	for(int i = 0; i < N; i++) {
		nums[i] = rand() % 1000;
	}

	cudaMalloc(&d_nums, byteSize);
	cudaMalloc(&d_nums_reduced, reduced_byteSize);

	cudaMemcpy(d_nums, nums.data(), byteSize, cudaMemcpyHostToDevice);

	int cpuSum = arraySum(nums);

	gpuReduction<<<grid, block, block * sizeof(int)>>>(d_nums, d_nums_reduced, N);
	cudaDeviceSynchronize();

	gpuReduction<<<1, block, block * sizeof(int)>>>(d_nums_reduced, d_nums_reduced, grid);
	cudaDeviceSynchronize();

	cudaMemcpy(&gpuResult, d_nums_reduced, sizeof(int), cudaMemcpyDeviceToHost);

	cout << "CPU Sum = " << cpuSum << endl;
	cout << "GPU Sum = " << gpuResult << endl;

	assert(cpuSum == gpuResult);

	cout << "Results Match.\n";

	cudaFree(d_nums);
	cudaFree(d_nums_reduced);

	return 0;
}