#include <iostream>
#include <thread>
#include <vector>
#include <semaphore>

using namespace std;

// Allow only 3 threads at a time
counting_semaphore<3> sem(3);

void worker(int id)
{
  // Take a permit
  sem.acquire();

  // Critical section
  cout << "Thread " << id << " entered\n";

  this_thread::sleep_for(chrono::seconds(2));

  cout << "Thread " << id << " leaving\n";

  // Return permit
  sem.release();
}

int main()
  vector<thread> threads;

  // Launch 10 threads
  for(int i=0;i<10;i++)
    threads.emplace_back(worker,i);

  // Wait for all threads
  for(auto &t : threads)
    t.join();

  return 0;
}