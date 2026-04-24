#include <iostream>
#include <vector>

using namespace std;

class Solution {
  public:

    void buildAdjList(vector<vector<int>>& edges, vector<vector<int>>& adjacencyList) {
      
      for(const auto& edge:edges) {
        int u = egde[0];
        int v = edge[1];

        adjacencyList[u].push_back(v);
        adjacencyList[v].push_back(u);
      }

    }

    bool check(int n, int m, vector<vector<int>> edges) {
      //int totalNodes = n;
      vector<vector<int>> adjacencyList(n);
      buildAdjList(edges, adjacencyList);
      
      
      
    }
};

int main() {

  return 0;
}