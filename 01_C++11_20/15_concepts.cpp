#include <iostream>
#include <concepts>

using namespace std;

template<typename T>
requires integral<T>
T sum(T a, T b) {
    return a + b;
}

int main() {

    cout << sum(10.1, 20.2) << endl;
    return 0;
}