#include <iostream>
#include <memory>
#include <vector>

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

    vector<Point*> pnts;
    pnts.push_back(new Point(2,3));

    for(Point *p : pnts) {
        delete p;
    }

    //to remove any dangling pointers
    pnts.clear();

    //Using smart pointers
    vector<std::unique_ptr<Point>> points;
    points.push_back(std::make_unique<Point>(2, 3));
    cout << "Using smart pointers.\n";
    points[0]->location();
    cout << endl;
    // No delete needed.

    return 0;
}