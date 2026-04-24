#include <iostream>
#include <vector>

using namespace std;


vector<vector<int>> buildAdjList(vector<vector<int>>& edges, int n) {
  vector<vector<int>> adjacencyList(n); 
  for(const auto& edge:edges) {
    int u = edge[0];
    int v = edge[1];

    //For undirected graph.
    adjacencyList[u].push_back(v);
    adjacencyList[v].push_back(u);
  }

  return adjacencyList;
}


int main() {

  return 0;
}