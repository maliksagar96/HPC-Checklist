#include <iostream>
#include <thread>
#include <vector>

using namespace std;

void findeven(vector<int> &data, vector<int> &evenOnly) {
	for(int i = 0;i<data.size();i++) {
		if(i%2==0) {
			evenOnly.push_back(data[i]);
		}
	}
}

void findodd(vector<int> &data, vector<int> &oddOnly) {
	for(int i = 0;i<data.size();i++) {
		if(i%2!=0) {
			oddOnly.push_back(data[i]);
		}
	}
}

int main() {

	int N = 20;
	vector<int> data(N, 0);
	vector<int> evenOnly;
	vector<int> oddOnly;

	for(int i = 0;i<N;i++) {
		data[i] = i;
	}

	thread t1(findeven, &data, &evenOnly);
	thread t2(findodd, &data, &oddOnly);

	t1.join();
	t2.join();

	for(int i = 0;i<evenOnly.size();i++) {
		cout << evenOnly[i] << endl;
	}

	return 0;
}