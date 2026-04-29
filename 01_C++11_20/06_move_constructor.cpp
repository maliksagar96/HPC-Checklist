/*
In this code we'll make a string class and we'll see what's the problem with copying objects. 
*/



#include <iostream>
#include <cstring>

/*
When printing this out we can see that there are 2 memory allocations which are taking place. Followed by 2 destructions. This is overkill. 
Is there a way somehow we can move the data directly into the m_name varialbe of the Entity class which is a string type class so ultimately is there a way to create the memory only once?
*/

// class String {

//     public:
//         String() = default;
//         //Constructor
//         String(const char* str) {
//             printf("Created.\n");
//             m_size = strlen(str);
//             m_data = new char[m_size];
//             strcpy(m_data, str);
//         }

//         //Copy constructor
//         String(const String &other) {
//             printf("Copied.\n");
//             m_size = other.m_size;
//             m_data = new char[m_size];
//             strcpy(m_data, other.m_data);
//         }

//         ~String() {
//             printf("Destroyed.\n");
//             delete m_data;
//         }

//     private:

//         char *m_data;
//         uint32_t m_size;
// };

// class Entity {
//     public:
//     Entity(const String& name):m_name(name)
//     {

//     }

//     private:
//     String m_name;
// };

// int main() {

//     Entity entity("Sagar");
//     return 0;

// }


/*
    Now is the time to see the move semantics in action. 
    In the code numbered 05 we learnt that the rvalues can be passed as an argument to the function and it will prefer that function call over any other function call. Lets make a move constructor now. 
*/

class String {

    public:
        String() = default;
        //Constructor
        String(const char* str) {
            printf("Created.\n");
            m_size = strlen(str);
            m_data = new char[m_size + 1];
            strcpy(m_data, str);
        }

        //Copy constructor
        String(const String &other) {
            printf("Copied.\n");
            m_size = other.m_size;
            m_data = new char[m_size + 1];
            strcpy(m_data, other.m_data);
        }

        String(String &&other) noexcept {
            printf("Moved.\n");
            m_size = other.m_size;
            m_data = other.m_data; // This is where magic is happening. We are rewiring the pointers that's all. 
            //Now to complete the process, we have to set the other pointer as null.
            other.m_data = nullptr;
            other.m_size = 0;
        }

        void Print() {
            for(int i = 0;i<m_size;i++) {
                printf("%c", m_data[i]);
            }
        }

        ~String() {
            printf("Destroyed.\n");
            delete[] m_data;
        }


    private:

        char *m_data;
        uint32_t m_size;
};

class Entity {
    public:
    Entity(const String& name):m_name(name)
    {

    }

    // Entity(String&& name):m_name((String&&)name) 
    Entity(String&& name):m_name(std::move(name)) 
    {

    }

    void PrintName() {
        m_name.Print();
    }

    
    private:
    String m_name;
};

int main() {

    Entity entity("Sagar");
    entity.PrintName();
    return 0;

}

