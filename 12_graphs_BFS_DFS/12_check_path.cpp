#include <iostream>
#include <vector>
#include <queue>

using namespace std;

class Solution {
  public:
    bool checkPath(int V, vector<vector<int>>& edges, int src, int dest) {
        vector<vector<int>> adj(V);

        for(auto edge:edges) {
          int u = edge[0];
          int v = edge[1];

          adj[u].push_back(v);
          adj[v].push_back(u);
        }

        vector<bool> visited(V, false);
        queue<int> q;
        q.push(src);
        visited[src] = true;

        while(!q.empty()) {
          int node = q.front();
          q.pop();
          
          if(node == dest) return true;

          for(int neighbour:adj[node]) {
            if(!visited[neighbour]) {
              q.push(neighbour);
              visited[neighbour] = true;
            }
          }
        }

        return false;        
    }
};
