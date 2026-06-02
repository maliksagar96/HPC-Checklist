#include <iostream>
#include <vector>
#include <random>
#include <cstdint>
#include <ranges>
#include <cassert>
#include <algorithm>

using namespace std;

void cpuRadixSort(vector<uint32_t> input, vector<uint32_t>& output) {
	int N = input.size();
	int buckets = 256;
	vector<int> histogram(buckets, 0);

	int mask = 0xFF;
	
	for(int shiftBits = 0;shiftBits < 32;shiftBits += 8) {
	
		fill(histogram.begin(), histogram.end(), 0);

		for(int number:input) {
			number = (number >> shiftBits) & mask;
			histogram[number]++;
		}

		//Histogram prefix sum	
		int currentSum = 0;

		for(int i = 0;i < buckets;i++) {
			int prefixSum = currentSum + histogram[i];
			histogram[i] = currentSum;
			currentSum = prefixSum;
		}

		//Stable Scatter 
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
  vector<uint32_t> cpuOutput(N);
  vector<uint32_t> gpuOutput(N);
	vector<uint32_t> quick_Sort(N);

  random_device rd;
  mt19937 generator(rd());
	uniform_int_distribution<uint32_t> distribution(0, UINT32_MAX);

  for(int i = 0; i < N; i++) {
    input[i] = distribution(generator);
		quick_Sort[i] = input[i];
  }
  
  cpuRadixSort(input, cpuOutput);

	ranges::sort(quick_Sort);

	for(int i = 0;i<N;i++) {
		assert(quick_Sort[i] == cpuOutput[i]);
	}

	cout << "Radix sort is correct.\n";

	return 0;
}