#include <iostream>
#include <vector>

using namespace std;

class Solution {
  public:
		   void edgeToadj(vector<vector<int>>& edges, vector<vector<int>>& adj) {
      for (auto& edge : edges) {
        // convert to 0-based indexing
        int u = edge[0] - 1;
        int v = edge[1] - 1;

        // safety check (optional but good)
        if (u < 0 || u >= adj.size() || v < 0 || v >= adj.size())
          continue;

        adj[u].push_back(v);
        adj[v].push_back(u);
      }
    }

		bool dfs(int node, vector<vector<int>>& adj, vector<bool>& visited, int count, int n) {
			if(count == n) return true;

			for(int neighbour:adj[node]) {
				if(!visited[neighbour]) {
					visited[neighbour] = true;
					if(dfs(neighbour, adj, visited, count+1, n)) {
						return true;
					}
					visited[neighbour] = false;
				} 
			}
			return false;
		}

    bool check(int n, int m, vector<vector<int>> edges) {
			//n = number of nodes.
			vector<vector<int>> adj(n);
			edgeToadj(edges, adj);

			vector<bool> visited(n, false);

			//Try starting from each node.
			for(int i = 0;i<n;i++) {
				visited[i] = true;

				if(dfs(i, adj, visited, 1, n)) {
					return true;
				}

				visited[i] = false;
			}

			return false;
    }
};

int main() {

    return 0;
}