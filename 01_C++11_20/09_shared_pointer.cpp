/*

Que - when does a shared pointer leaks memory?
Ans - in circular referencing. 

Que - Why?
Ans At the end of the scope the local objects a and b are destroyed. But the object B::ptrA and object A::ptrB still exist. B::ptrA still owns A and A::ptrB still owns B. 

Que - What if we want to use the circular referencing but don't want memory leak, then what?
Ans - use weak pointer instead. 

*/

// #include <iostream>
// #include <memory>

// using namespace std;


// class B;

// class A {
//     public:

//     shared_ptr<B> ptrB;

//     A() {
//         "A object created.\n";
//     }

//     ~A() {
//         "A object destroyed.\n";
//     }
// };

// class B {
// 	public:
	
// 	shared_ptr<A> ptrA;
// 	B() {
// 		cout << "B object created.\n";
// 	}

// 	~B() {
// 		cout << "B object destroyed.\n";
// 	}
// };


// int main() {

// 	shared_ptr<A> a = make_shared<A>();
// 	shared_ptr<B> b = make_shared<B>();

// 	a->ptrB = b;
// 	b->ptrA = a;

// 	cout << a.use_count() << endl;
// 	cout << b.use_count	() << endl;

// }


#include <iostream>
#include <memory>

using namespace std;

class B;

class A {
public:

  weak_ptr<B> ptrB;

  A() {
    cout << "A created.\n";
  }

  ~A() {
    cout << "A destroyed.\n";
  }
};

class B {
public:

  // weak_ptr does NOT increase reference count
  weak_ptr<A> ptrA;

  B() {
    cout << "B created.\n";
  }

  ~B() {
    cout << "B destroyed.\n";
  }
};

int main() {

  shared_ptr<A> a = make_shared<A>();
  shared_ptr<B> b = make_shared<B>();

  // Circular connection
  a->ptrB = b;
  b->ptrA = a;

  cout << "A count = " << a.use_count() << endl;
  cout << "B count = " << b.use_count() << endl;

  return 0;
}