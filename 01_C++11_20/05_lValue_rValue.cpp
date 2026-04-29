/*
    The following code makes you understand the basics of the lvalue and rvalue. 
*/

#include <iostream>

using namespace std;

// void printName(string name) {
//     cout << name << endl;
// }

// int main () {

//     //lvalue            rvalue
//     string firstName = "Sagar";
//     string secondName = " Malik";

//     //lvalue           rvalue
//     string fullname = firstName + secondName;
//     printName(fullname);
//     printName(firstName + secondName);
//     //By defualt the function can take both lvalue and rvalue. The rvalues are temporary. lets see in the following code how do we differentiate temporary values from the non temporary ones.

//     return 0;
// }

// void printName(string& name) {
//     cout << name << endl;
// }


// int main() {
//     string firstName = "Sagar";
//     string secondName = " Malik";

//     //lvalue           rvalue
//     string fullname = firstName + secondName;
//     printName(fullname);
//     printName(firstName + secondName);
//     //Now this function will take only the lvalues, only the values which are already stored in a variable. 
//     //The function will not entertian any rvalues. 

// }

// void printName(const string& name) {
//     cout << name << endl;
// }

// int main() {
//     string firstName = "Sagar";
//     string secondName = " Malik";

//     string fullname = firstName + secondName;
//     printName(fullname);
//     printName(firstName + secondName);
//     // Just by adding a const keyword now it accepts both lvalue and rvalue. This is more of a rule.      
// }


// Now when we use the following functions we can see the difference betweem a lvalue or rvalue. 
// it is very important to observe if there is 
void printName(const string& name) {
    cout <<"[lvalue]: "<< name << endl;
}

void printName(string&& name) {
    cout << "[rvalue]: "<< name << endl;
}

int main() {
    string firstName = "Sagar";
    string secondName = " Malik";

    string fullname = firstName + secondName;
    printName(fullname);
    printName(firstName + secondName);
    
}

