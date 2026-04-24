#include <iostream>
#include <vector>

using namespace std;

vector<vector<int>> adjacencyToEdge(vector<vector<int>>& adj) {
	int n = adj.size();
	vector<vector<int>> edges(n); 

	for(int u = 0;u<n;u++) {
		for(int v:adj[u]) {
			if(u<v) {
				edges.push_back({u, v});
			}
		}
	}

	return edges;
}

int main() {

	return 0;
}