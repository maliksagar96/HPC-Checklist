#include <iostream>
#include <memory>

using namespace std;

class Point{

	private:
	int *x;
	int *y;

	public:
	Point(int a, int b) {
		x = new int(a);
		y = new int(b);
		cout << "Point p created with coordinates:("<<*x<<","<<*y<<")\n";
	}

	//Copy constructor
	Point(const Point &other) {
		x = new int(*other.x);
		y = new int(*other.y);
	}

	//Copy assignment operator
	Point& operator=(const Point &other) {
		if(this != &other) {
			if(other.x != nullptr) {
				if(x != nullptr) {
					*x = *other.x;
				}

				else {
					x = new int(*other.x);
				}
			}
			
			else {
				delete x;
				//Que - Why is there a need to write x = nullptr. 
				//Ans - Well the variable x still contains the old address which is now free. Such a pointer is called dangling pointer. We need to write x = nullptr.
				x = nullptr; 
			}

			if(other.y) {
				if(y != nullptr) {
					*y = *other.y;
				}
				else {
					y = new int(*other.y);
				}
			}

			else {
				delete y;
				y = nullptr;
			}
			
		} 

		return *this;
	}

	//Move constructor
	//Que - Well we wrote const Point &other in copy constructor and copy assignment operator why didn't we write const Point && here?
	//Ans - Because we need to change the resource itself.
	Point(Point &&other) noexcept {
		x = other.x;
		y = other.y;
		other.x = nullptr;
		other.y = nullptr;
	}
	//Move assignmnet operator
	Point& 
	~Point() {
		cout << "Destructor for Point class.\n";
		delete x;
		delete y;
	}
};

int main() {

	cout << "Entering the scope.\n";
	{
		std::unique_ptr<Point> p = std::make_unique<Point>(2,3);
	}
	cout << "Exited the scope.\n";
	return 0;
}