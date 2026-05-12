/*  Que - What is the difference between a shared pointer and a weak pointer?
    Ans - Well when you copy a shared pointer to another shared pointer then the data is copied 
*/

#include <iostream>
#include <memory>


using namespace std;

class Entity {
    public:
    Entity() {
        cout << "Object Created.\n";        
    }

    //Copy constructor
    Entity(const Entity& other) {
        cout << "Copy constructor called.\n";
    }

    Entity(Entity &&other) noexcept {
        cout << "Move constructor called.\n";
    }

    ~Entity() {
        cout << "Object destroyed.\n";
    }

    void Print() {
        cout << "Print entity.\n";
    }
};

int main() {

	shared_ptr<Entity> e0 = make_shared<Entity>();
	cout << "e0 ref count = "<<e0.use_count()<<endl;

	weak_ptr<Entity> wp = e0;

	//No increase in reference count. 
	cout << "After creation of weap pointer e0 ref count = "<<e0.use_count()<<endl;

	//To access the info of the shared pointer we have to temporarily convert this to shared pointer and then we can access the objects methods and other data. 

	shared_ptr<Entity> temp = wp.lock();

	if(temp) {
		temp->Print();
	}

	return 0;
}