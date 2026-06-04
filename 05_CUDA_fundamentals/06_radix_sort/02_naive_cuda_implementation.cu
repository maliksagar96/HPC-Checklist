#include <iostream>
#include <vector>
#include <random>
#include <cassert>
#include <cstdint>

using namespace std;

__global__ void buildHistogram(uint32_t *input,int *histogram,int N,int shiftBits) {

  int globalTID = blockIdx.x * blockDim.x + threadIdx.x;

  if(globalTID < N) {
    int mask = 0xFF;
    int bucket = (input[globalTID] >> shiftBits) & mask;
    atomicAdd(&histogram[bucket],1);
  }
}

__global__ void scatterElements(uint32_t *input, uint32_t *output, int *prefix, int *offsets, int N, int shiftBits) {

  int globalTID = blockIdx.x * blockDim.x + threadIdx.x;

  if(globalTID < N) {

    int mask = 0xFF;

    uint32_t value = input[globalTID];

    int bucket = (value >> shiftBits) & mask;

    // Every thread gets a unique local position in its bucket.
    int localOffset = atomicAdd(&offsets[bucket],1);

    int finalPosition = prefix[bucket] + localOffset;

    output[finalPosition] = value;
  }
}

void radixSort(vector<uint32_t> input,vector<uint32_t>& output) {

  int N = input.size();

  int numberOfBuckets = 256;

  vector<int> histogram(numberOfBuckets);

  int mask = 0xFF;

  for(int shiftBits = 0;shiftBits < 32;shiftBits+=8) {

    fill(histogram.begin(), histogram.end(), 0);

    // STEP 1: Build histogram
    for(int number:input) {
      number = (number >> shiftBits) & mask;
      histogram[number]++;
    }

    // STEP 2: Exclusive prefix sum
    int currentSum = 0;

    for(int i = 0;i<numberOfBuckets;i++) {
      int prefixSum = currentSum + histogram[i];
      histogram[i] = currentSum;
      currentSum = prefixSum;
    }

    // STEP 3: Stable scatter
    for(int i = 0;i<N;i++) {

      int number = (input[i] >> shiftBits) & mask;

      output[histogram[number]] = input[i];

      histogram[number]++;
    }

    input = output;
  }
}

int main() {

  int N = 1 << 16;

  int byteSize = N * sizeof(uint32_t);

  vector<uint32_t> input(N);

  vector<uint32_t> output(N), gpuResult(N);

  random_device rd;

  mt19937 generator(rd());

  uniform_int_distribution<uint32_t> distribution(0, UINT32_MAX);

  // Generate random numbers
  for(int i = 0;i < N;i++) {
    input[i] = distribution(generator);
  }

  // CPU radix sort
  radixSort(input, output);

  int *d_histogram, *d_prefix, *d_offsets;

  uint32_t *d_input, *d_output;

  cudaMalloc(&d_input, byteSize);
  cudaMalloc(&d_output, byteSize);

  cudaMalloc(&d_histogram, 256 * sizeof(int));
  cudaMalloc(&d_prefix, 256 * sizeof(int));
  cudaMalloc(&d_offsets, 256 * sizeof(int));

  cudaMemcpy(d_input, input.data(), byteSize, cudaMemcpyHostToDevice);

  int block = 256;

  int grid = (N + block - 1) / block;

  vector<int> histogram(256), prefix(256);

  for(int shiftBits = 0;shiftBits < 32;shiftBits+=8) {

    // Reset histogram
    cudaMemset(d_histogram, 0, 256 * sizeof(int));

    // STEP 1: Build histogram
    buildHistogram<<<grid, block>>>(d_input, d_histogram, N, shiftBits);

    cudaDeviceSynchronize();

    // Copy histogram back to CPU
    cudaMemcpy(histogram.data(), d_histogram, 256 * sizeof(int), cudaMemcpyDeviceToHost);

    // STEP 2: Exclusive prefix sum on CPU
    int currentSum = 0;

    for(int i = 0;i < 256;i++) {
      prefix[i] = currentSum;
      currentSum += histogram[i];
    }

    // Copy prefix sum to GPU
    cudaMemcpy(d_prefix, prefix.data(), 256 * sizeof(int), cudaMemcpyHostToDevice);

    // Reset offsets
    cudaMemset(d_offsets, 0, 256 * sizeof(int));

    // STEP 3: Scatter elements
    scatterElements<<<grid, block>>>(d_input, d_output, d_prefix, d_offsets, N, shiftBits);

    cudaDeviceSynchronize();

    // Swap input/output
    swap(d_input, d_output);
  }

  cudaMemcpy(gpuResult.data(), d_input, byteSize, cudaMemcpyDeviceToHost);

  // Validation
  for(int i = 0;i < N;i++) {
    assert(gpuResult[i] == output[i]);
  }

  cout << "Results match.\n";

  cudaFree(d_input);
  cudaFree(d_output);
  cudaFree(d_histogram);
  cudaFree(d_prefix);
  cudaFree(d_offsets);

  return 0;
}