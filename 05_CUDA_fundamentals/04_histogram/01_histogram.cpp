#include <iostream>
#include <vector>
#include <ctime>

using namespace std;

void computeHistogram(vector<int>& input, vector<int>& histogram) {

	int size = input.size();
	int bins = histogram.size();

	for(int i = 0;i<size;i++) {
		histogram[input[i]%bins]++;
	}
}

int main() {

	int size = 1 << 10;
	int bins = 10;
	vector<int> input(size);
	vector<int> histogram(bins, 0);

	srand(time(0));

	for(int i = 0;i < size;i++) {
		input[i] = rand() % 100;
	}

	computeHistogram(input, histogram);

	return 0;
}