/*
	Calling a static function means we only have to give reference to the function. 
*/

#include <iostream>
#include <vector>
#include <thread>

using namespace std;

class Base {

	public:

	static void run(int n) {
		while(n > 0) {
			cout << n-- << endl;
		}
	}
};

int main() {
  
	

	thread t1(&Base::run, 10);
	t1.join();

	return 0;
}