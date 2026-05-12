/*
Que - What are smart pointers?
Ans - Whenever we have to allocate dynamic memory we have to use the key word new and delete. Smart pointers are a way where we don't have to use the keywords new and delete. 

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

    std::unique_ptr<Entity> entity = std::make_unique<Entity>();
    //std::unique_ptr<Entity> e0 = entity; // Compilation error. 
    
    //How do you copy the content of the object created by unique pointer. 
    std::unique_ptr<Entity> e0 = std::make_unique<Entity>(*entity); 

    Entity e1;    
    Entity e2 = std::move(e1);


    return 0;
}