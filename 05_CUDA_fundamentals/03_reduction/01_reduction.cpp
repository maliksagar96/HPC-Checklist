#include <iostream>
#include <vector>
#include <ctime>
#include <cassert>

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
