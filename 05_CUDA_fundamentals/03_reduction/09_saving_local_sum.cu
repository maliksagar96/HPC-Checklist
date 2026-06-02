#include <iostream>
#include <vector>
#include <ctime>
#include <cassert>
#include <cuda_runtime.h>

using namespace std;

__device__ int d_sum;

int arraySum(vector<int>& nums) {
	cout << "Naive array Sum.\n"; 
	int sum = 0;
	for(int x:nums) {
    sum += x;
	}
	return sum;
}


__global__ void gpuReduction(int *nums, int *reduced_nums, int N) {

  extern __shared__ int shmem[];
  int tx = threadIdx.x;
  int tid1 = 2 * blockDim.x * blockIdx.x + tx;
  int tid2 = tid1 + blockDim.x;

  int sum = 0;

  if(tid1 < N)
    sum += nums[tid1];

  if(tid2 < N)
    sum += nums[tid2];

  shmem[tx] = sum;

  __syncthreads();

  for(int stride = blockDim.x / 2; stride > 32; stride /= 2) {

    if(tx < stride)
      shmem[tx] += shmem[tx + stride];

    __syncthreads();
  }

  if(tx < 32) {
    sum = shmem[tx] + shmem[tx + 32];		
    unsigned mask = 0xffffffff;
		//No need to write syncthreads() in between because the threads in a warp are already in sync. 
    sum += __shfl_down_sync(mask, sum, 16);
    sum += __shfl_down_sync(mask, sum, 8);
    sum += __shfl_down_sync(mask, sum, 4);
    sum += __shfl_down_sync(mask, sum, 2);
    sum += __shfl_down_sync(mask, sum, 1);

    if(tx == 0)
      reduced_nums[blockIdx.x] = sum;

			if(gridDim.x == 1) {
				d_sum = sum;
			}
  }
}

int main() {

	int N = 1 << 12;
	int byteSize = N * sizeof(int);
	int *d_nums;
	int *d_nums_reduced = nullptr;
	
	int gpuResult;

	int block = 256;
	int grid = (N + 2*block - 1) / (2 * block);
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
	
	// cudaMemcpy(&gpuResult, d_nums_reduced, sizeof(int), cudaMemcpyDeviceToHost);
	cudaMemcpyFromSymbol(&gpuResult, d_sum, sizeof(int));

	cout << "CPU Sum = " << cpuSum << endl;
	cout << "GPU Sum = " << gpuResult << endl;

	assert(cpuSum == gpuResult);

	cout << "Results Match.\n";

	cudaFree(d_nums);
	cudaFree(d_nums_reduced);

	return 0;
}