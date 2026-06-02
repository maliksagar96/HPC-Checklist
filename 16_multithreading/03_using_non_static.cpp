/*
	Calling non static functions of a class. A reference to the function and the object both have to be given. 
*/

#include <iostream>
#include <vector>
#include <thread>

using namespace std;

class Base {

	public:

	void run(int n) {
		while(n > 0) {
			cout << n-- << endl;
		}
	}
};

int main() {
  
	Base b;

	thread t1(&Base::run, &b, 10);
	t1.join();

	return 0;
}