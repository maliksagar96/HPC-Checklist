#include <iostream>
#include <thread>
#include <mutex> 
#include <condition_variable>

using namespace std;

std::condition_variable cv;
std::mutex m;

long long balance = 0;

void addBalance(int money) {
	std::lock_guard<mutex> lg(m);
	balance += money;    
	cout << "Amount Added to account.\n";
	cout << "Current amount = "<<balance<<endl;
	cv.notify_one();
}

void withDrawBalance(int money) {

	std::unique_lock<mutex> ul(m);
	cv.wait(ul, []{return (balance !=0 ) ? true:false;});

	if(balance >= money) {
		balance -= money;
		cout << "Money withdraw. Remaining balance = "<<balance<< endl;
	}
	else {
		cout << " Low balance. Money can't be withdrawn. Balance = "<<balance<<endl;
	}
}

int main() {
	std::thread t1(withDrawBalance, 500);
	std::thread t2(addBalance, 600);
	t1.join();
	t2.join();

	return 0;
}