#include <iostream>
#include <vector>
#include <ranges>
#include <algorithm>

using namespace std;

int main() {

  vector<int> arr = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

  // --------------------------------------------------
  // ranges::sort
  // --------------------------------------------------

  ranges::sort(arr);

  // --------------------------------------------------
  // views::filter
  // Keep only even numbers
  // --------------------------------------------------

  auto evenNumbers = views::filter(arr, [](int x) {return x % 2 == 0;});

  // --------------------------------------------------
  // views::transform
  // Multiply each number by 10
  // --------------------------------------------------

  auto multiplied = views::transform(evenNumbers, [](int x) { return x * 10;});

  cout << "Filtered and transformed:\n";

  for(int x : multiplied) {
    cout << x << " ";
  }

  cout << "\n\n";

  // --------------------------------------------------
  // views::reverse
  // --------------------------------------------------

  auto reversed = views::reverse(arr);

  cout << "Reversed:\n";

  for(int x : reversed) {
    cout << x << " ";
  }

  cout << "\n\n";

  // --------------------------------------------------
  // views::take
  // Take first 5 elements
  // --------------------------------------------------

  auto firstFive = views::take(arr, 5);

  cout << "First five:\n";

  for(int x : firstFive) {
    cout << x << " ";
  }

  cout << "\n\n";

  // --------------------------------------------------
  // views::drop
  // Skip first 5 elements
  // --------------------------------------------------

  auto afterFive = views::drop(arr, 5);

  cout << "After dropping five:\n";

  for(int x : afterFive) {
    cout << x << " ";
  }

  cout << "\n\n";

  // --------------------------------------------------
  // ranges::find
  // --------------------------------------------------

  auto it = ranges::find(arr, 7);

  if(it != arr.end()) {
    cout << "Found: " << *it << "\n";
  }

  return 0;
}