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

int arrayReduction(vector<int>& nums){

    cout << "Reduction sum.\n";
    int size = nums.size();
    
    for(int stride = 1;stride < size; stride *= 2) {
        for(int i = 0;i+stride<size;i += 2*stride) {
            nums[i] = nums[i] + nums[i + stride];
        }
    }

    return nums[0];
}

//Naive gpu reduction sum
__global__ void gpuReduction(int *nums, int stride) {

    int tid = blockdim.x * blockIdx.x + threadIdx.x;

    if((tid < stride)) {
        nums[tid] = nums[tid] + nums[tid + stride];
    }
    }

int gpuKernelReduction(vector<int>& nums){

    cout << "Reduction sum.\n";
    int size = nums.size();
    
    int block = 256;
    int grid = (size + block - 1)/block;

    for(int stride = size/2;stride >= 1; stride /= 2) {
        gpuReduction<<<grid, block>>>(nums, stride);
    }

    return nums[0];
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

    assert(cpuSum == reductionSum);
    cout << "Results Match.\n";

    return 0;
}
