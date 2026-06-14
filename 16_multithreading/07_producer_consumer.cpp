/*
	Simple producer consumer demo. 
*/

#include <iostream>
#include <thread>
#include <deque>
#include <mutex>
#include <condition_variable>

using namespace std;

deque<int> shared_buffer;
mutex shbf_mtx;
condition_variable cnd;

void producer(int val) {
	while(val) {
		unique_lock<mutex> locker(shbf_mtx);	
		cnd.wait(locker, []{return shared_buffer.size() < 50;});
		cout<<"Produced : "<<val<<endl;
		shared_buffer.push_back(val--);
		locker.unlock();
		cnd.notify_one();
	} 
}

void consumer() {
	//
	while(1) {
		unique_lock<mutex> locker(shbf_mtx);
		cnd.wait(locker, []{return shared_buffer.size() > 0;});
		cout << "Consuming shared buffer: "<<shared_buffer.front()<<endl;
		shared_buffer.pop_front();
		locker.unlock();
	}
}


int main() {

	thread t1(producer, 100);
	thread t2(consumer);

	t1.join();
	t2.join();

	return 0;
}