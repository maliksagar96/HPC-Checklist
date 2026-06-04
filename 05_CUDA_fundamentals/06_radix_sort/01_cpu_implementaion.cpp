#include <iostream>
#include <vector>
#include <random>
#include <cstdint>

using namespace std;

void radixSort(vector<uint32_t>& input, vector<uint32_t>& output) {

  int N = input.size();
  // We process 8 bits at a time. So total buckets = 2^8 = 256.
  int numberOfBuckets = 256;
  vector<int> histogram(numberOfBuckets);

  // 8 bit mask
  int mask = 0xFF;
  // 4 passes:
  // pass 0 -> bits 0-7
  // pass 1 -> bits 8-15
  // pass 2 -> bits 16-23
  // pass 3 -> bits 24-31
  for(int shiftBits = 0;shiftBits < 32;shiftBits+=8) {
    //Reset histogram at every pass.
    fill(histogram.begin(), histogram.end(), 0);

    // STEP 1:  Build histogram
    for(int number:input) {
      number = (number >> shiftBits) & mask;
      histogram[number]++;
    }    
    // STEP 2: Convert histogram into exclusive prefix sum
    int currentSum = 0;
    for(int i = 0;i<numberOfBuckets;i++) {
      int prefixSum = currentSum + histogram[i];
      histogram[i] = currentSum;
      currentSum = prefixSum;
    }
    // STEP 3: Stable scatter. Place elements into correct positions in output.
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

  vector<uint32_t> input(N);

  // Final sorted array
  vector<uint32_t> output(N);

  random_device rd;
  mt19937 generator(rd());

  uniform_int_distribution<uint32_t> distribution(0, UINT32_MAX);

  // Generate random 32-bit integers
  for(int i = 0; i < N; i++) {
    input[i] = distribution(generator);
  }

  radixSort(input, output);

  // Print first 20 sorted elements
  for(int i = 0; i < 20; i++) {
    cout << output[i] << endl;
  }

  return 0;
} 