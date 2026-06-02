#include <iostream>
#include <thread>

using namespace std;

void fun(int n) {
  while(n > 0) {
    cout << n-- << endl;
  }
}

int main() {

  thread t1(fun, 10);
  cout << "In main() now.\n";

  //Once we declare any thread as a detched thread then the ownership of the thread is released permanently. 
  t1.detach();//non blocking command.
  cout << "Cheching if joinable.\n";

  //Before joining always check if the thread is joinable or not. This will eliminate the problem of double joining. 
  if(t1.joinable())
    t1.join();

  return 0;
}





