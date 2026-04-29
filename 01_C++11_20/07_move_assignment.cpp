/*
    Example for move assignement operator. 
*/
#include <iostream>
#include <cstring>

class String {

    public:
String() : m_data(nullptr), m_size(0) {}
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
            m_data = other.m_data;             
            other.m_data = nullptr;
            other.m_size = 0;
        }

        String& operator=(String &&other) noexcept {					
			if(this != &other)
			{
				delete[] m_data; // Move assignemnt is exactly like a move constructor. Just delete the already existing data and that's all. 
				printf("Moved.\n");
				m_size = other.m_size;
            	m_data = other.m_data;             	
            	other.m_data = nullptr;
            	other.m_size = 0;
            }            
			return *this;
        }

        void Print() {
            for(int i = 0;i<m_size;i++) {
                printf("%c", m_data[i]);
            }
			std::cout<<std::endl;
        }

        ~String() {
            printf("Destroyed.\n");
            delete[] m_data;
        }


    private:

        char *m_data;
        uint32_t m_size;
};

int main() {

    String Apple("Apple");

    String dest;

    std::cout << "Apple: ";
    Apple.Print();
    std::cout << "Dest: ";
    dest.Print();

    dest = std::move(Apple);

    std::cout << "Apple: ";
    Apple.Print();
    std::cout << "Dest: ";
    dest.Print();

    return 0;

}

