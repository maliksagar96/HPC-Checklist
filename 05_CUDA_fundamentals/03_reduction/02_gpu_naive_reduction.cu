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
__global__ void gpuReduction(int *nums, int stride, int N) {
	int tid = blockDim.x * blockIdx.x + threadIdx.x;

	if((tid % (2 * stride) && tid + stride < N)) {
		nums[tid] = nums[tid] + nums[tid + stride];
	}
}

/*
	Que - What is bad about this design?
	Ans - So many things are bad with this design. 
	1) All the threads in a warp are not active. So the occupancy will be very low. 
	2) The arithmenatic instensity is very low. There are 3 load/store operations and only 1 computation. 
	3) GPU kernel is called for each stride. From 2nd call onwards the number of active threads become half of the current active threads. 

*/

int gpuKernel(vector<int> &nums) {

	int N = nums.size();
	int byteSize = N * sizeof(int);
	int *d_nums;
	int gpuResult;

	int block = 256;
	int grid = (N + block - 1)/block;

	cudaMalloc(&d_nums, byteSize);
	cudaMemcpy(d_nums, nums.data(), byteSize, cudaMemcpyHostToDevice);

	for(int stride = 1;stride<N;stride *= 2) {
		gpuReduction<<<grid, block>>>(d_nums, stride, N);
	}

	cudaMemcpy(&gpuResult, d_nums, sizeof(int), cudaMemcpyDeviceToHost);
	return gpuResult;

}




int main() {

	int size = 1 << 4;
	vector<int> nums(size, 0);

	srand(time(0));
	for(int i = 0;i<size;i++) {
		nums[i] = rand() % 1000;
	}

	int cpuSum = arraySum(nums);
	int reductionSum = arrayReduction(nums);
	int gpuResult = gpuKernel(nums);

	assert(cpuSum == gpuResult);
	cout << "Results Match.\n";

	return 0;
}
