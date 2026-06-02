/*
	Lambda functions are valid for passing them in thread. 
*/

#include <iostream>
#include <vector>
#include <thread>

using namespace std;

int main() {
  
	auto fun = [](int x){
		while(x > 0) {
			x--;
			cout << x << endl;
		}
	};

	thread t1(fun, 10);
	t1.join();

	return 0;
}