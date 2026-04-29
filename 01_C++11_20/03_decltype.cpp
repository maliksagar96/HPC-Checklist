#include <iostream>

using namespace std;

int main() {

    const int x = 10;
    decltype(x) b = x;
    //b = 20;   Compilation error. decltype preserves const.

    
    int y = 20;
    decltype((y)) c = y; //int& and not int. c is a reference to y.

    y = 30;
    cout << c << endl;


    return 0;
}