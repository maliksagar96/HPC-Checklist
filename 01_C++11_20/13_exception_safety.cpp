#include <iostream>

using namespace std;

void foo() noexcept {
	int a = 2;
	if(a == 2) {
		throw runtime_error("Terminated");
	}

	else {
		cout <<"No errors in foo.\n";
	}
  
}

int main() {

  try {
    foo();
  }
  catch(const exception &e) {
    cout << e.what() << "\n";
  }

  cout << "Foo was executed.\n";

  return 0;
}