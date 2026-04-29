#include <iostream>
#include <typeinfo>
#include <vector>

using namespace std;

int main() {

    const int x = 10;
    int z = x;
    //Drops const.
    auto y = x;
    //Both prints i. Type id doesn't take into the account const. 
    cout << "Type of x = "<<typeid(x).name() << endl;    
    cout << "Type of y = "<<typeid(y).name() << endl;

    vector<int> vec = {1,2,3};
    cout << "Type of vec = " << typeid(vec).name() << endl;

    //This is list not a vector.
    auto avec = {1,2,3};
    cout << "Type of avec = " << typeid(avec).name() << endl;

    //type is int not double.
    auto a = 1/2;
    cout << "Type of a = " << typeid(a).name() << endl;

    //Should be passed by reference otherwise it makes a copy.
    for(auto &i:vec) {
        cout << i << endl;
    }

    int ab = 20;
    int &bc = ab;
    auto ca = bc; //Looses reference as well. For reference auto &ca.
    ca = 30;

    cout << "ab = "<< ab << endl;

}