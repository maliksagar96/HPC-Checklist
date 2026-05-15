#include <iostream>
#include <utility>

using namespace std;

void inner(int &&num) {
    cout << "This is the rvalue function. num: "<< num << endl;
}

void inner(int &num) {
    cout << "This is the lvalue function. num : "<< num << endl;
}

template<typename T> 
void wrapper(T&& arg) {
    inner(std::forward<T>(arg));
}

int main() {

    int x = 5;
    wrapper(x);
    wrapper(50);
    return 0;
}