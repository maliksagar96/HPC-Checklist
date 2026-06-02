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
__global__ void gpuReduction(int *nums, int *result, int N) {

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

	for(int stride = 1;stride<blockDim.x;stride *= 2) {
		if(tx % (2*stride) == 0 && tx + stride < blockDim.x) {
			shmem[tx] += shmem[tx + stride];
		}
		__syncthreads();
	}

	if(tx == 0) {
		atomicAdd(result, shmem[0]);
	}
}

/*
	Que - What is bad about this design?
	Ans - This is a better approach then the last one but still it is lacking in many things. 
	1) Warp Divergence - More and more threads become idle every iteration. 
	2) Too many thread synchronisations. For each stride. 
	3) Atomic add is slow. 
	4) GPU kernel is called for each stride. From 2nd call onwards the number of active threads become half of the current active threads. 

*/

int main() {

	int N = 1 << 4;
	int byteSize = N * sizeof(int);

	int *d_nums;
	int *d_result;

	int gpuResult = 0;

	int block = 256;
	int grid = (N + block - 1) / block;

	vector<int> nums(N, 0);

	srand(time(0));

	for(int i = 0; i < N; i++) {
		nums[i] = rand() % 1000;
	}

	cudaMalloc(&d_nums, byteSize);
	cudaMalloc(&d_result, sizeof(int));

	cudaMemcpy(d_nums, nums.data(), byteSize, cudaMemcpyHostToDevice);
	cudaMemcpy(d_result, &gpuResult, sizeof(int), cudaMemcpyHostToDevice);

	int cpuSum = arraySum(nums);

	gpuReduction<<<grid, block, block * sizeof(int)>>>(d_nums, d_result, N);

	cudaDeviceSynchronize();

	cudaMemcpy(&gpuResult, d_result, sizeof(int), cudaMemcpyDeviceToHost);

	cout << "CPU Sum = " << cpuSum << endl;
	cout << "GPU Sum = " << gpuResult << endl;

	assert(cpuSum == gpuResult);

	cout << "Results Match.\n";

	cudaFree(d_nums);
	cudaFree(d_result);

	return 0;
}