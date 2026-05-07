#include <iostream>
#include <vector>
#include <queue>

using namespace std;

class Solution {
  public:
    int minEdges(int V, vector<vector<int>>& edges, int u, int v) {
		
			vector<vector<int>> adj(V);
		
			// Convert edge list to adj list
			for(auto edge : edges) {
				int e0 = edge[0];
				int e1 = edge[1];

				adj[e0].push_back(e1);
				adj[e1].push_back(e0);
			}

			vector<int> dist(V, -1);
			queue<int> q;

			q.push(u);
			dist[u] = 0; //self distance

			while(!q.empty()) {
				int node = q.front();
				q.pop();
				if(node == v) return dist[v];

				for(int neighbour:adj[node]) {
					if(dist[neighbour] == -1) {
							dist[neighbour] = dist[node] + 1;
							q.push(neighbour);
					}
				}
			}
			 
			return -1; //if not reachable
			
    }
};


int main() {

    return 0;
}