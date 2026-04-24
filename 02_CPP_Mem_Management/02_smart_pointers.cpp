#include <iostream>
#include <memory>

using namespace std;

class Point {
    float x, y;
    public:
    Point(float x, float y):x(x), y(y) {}
    float getx() const {
        return x;
    }
    void location() {
        cout << "x = "<<x<<", y = "<<y;
  
    }
};

int main() {
    std::unique_ptr<Point> p = std::make_unique<Point>(2,3);

    cout << p->getx() << endl;
    p->location();
    cout << endl;
}