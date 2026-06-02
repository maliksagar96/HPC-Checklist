#include <iostream>
#include <mutex>
#include <thread>

using namespace std;

void addMoney(int *money, int amount, mutex *m) {

	//Blocking call
	m->lock();
	//The difference between money and *money is so small and the result changes by a lot. 
	*money += amount;
	m->unlock();
}

int main() {

	int myAmount = 0;
	mutex m;

	thread t1(addMoney, &myAmount, 10, &m);
	thread t2(addMoney, &myAmount, 15, &m);

	t1.join();
	t2.join();


	cout << "Total Amount = "<< myAmount << endl;

	return 0;
}