#include <iostream>

using namespace std;

int main() {

    //Inline lambda function. 
    auto f = [](int a, int b) { return a + b;};
    cout << f(2, 3) << endl;

    int x = 10;
    int y = 20;

    auto modify_local = [&]() {x += 5;};
    modify_local();
    cout << x << endl;

    int xy = 30;

    //auto modifyXY = [=]() {  xy += 6;  };//Readonly, xy can't be changed.

    //Changes the local xy.
    auto modifyXY = [=]() mutable { 
        cout <<"xy local before change = " << xy << endl;        
        xy += 7;
        cout <<"xy local after change = " << xy << endl;        
    };
    
    modifyXY();

    cout << xy << endl;



    return 0;
}