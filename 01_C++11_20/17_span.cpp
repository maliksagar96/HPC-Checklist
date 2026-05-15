#include <iostream>
#include <span>

using namespace std;

void usingPointer(int *arr, int size) {

  cout << "Pointer version:\n";

  for(int i = 0; i < size; i++) {
    cout << arr[i] << " ";
  }

  cout << "\n\n";
}

void usingSpan(span<int> arr) {

  cout << "Span version:\n";

  for(int i = 0; i < arr.size(); i++) {
    cout << arr[i] << " ";
  }

  cout << "\n";
}

int main() {

  int a[5] = {10,20,30,40,50};

  usingPointer(a, 3);  
  // programmer accidentally passed wrong size

  usingSpan(a);

  return 0;
}