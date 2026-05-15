#include <iostream>
#include <optional>

using namespace std;

std::optional<string> getSomeString(bool flag) {
	if(flag) return "True Flag\n";
	else return {};
}

int main() {

	if(auto myStr = getSomeString(false))   cout << *myStr << endl;
	else cout << "No value\n";

	return 0;
}