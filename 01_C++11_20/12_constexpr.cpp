#include <iostream>

using namespace std;

constexpr int sum(int a, int b) {return a+b;}
int main() {

    int a = 5, b = 7;
    int c = a + b;
    cout << sum(c, b) << endl;


    return 0;
}