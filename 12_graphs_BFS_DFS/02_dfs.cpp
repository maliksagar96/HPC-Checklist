#include <iostream>

using namespace std;

class Solution {
  public:
    void dfsHelper(int node, vector<vector<int>>& adj, vector<int>& result, vector<int>& visited) {
      visited[node] = 1;
      result.push_back(node);
      for(int neighbour : adj[node]) {
        if(!visited[neighbour]) {
          dfsHelper(neighbour, adj, result, visited);
        }
      }
    }

    vector<int> dfs(vector<vector<int>>& adj) {
        int totalNodes = adj.size();
        vector<int> visited(totalNodes, 0);
        vector<int> result;
        dfsHelper(0, adj, result, visited);
        return result;
    }
};

int main() {
  return 0;
}