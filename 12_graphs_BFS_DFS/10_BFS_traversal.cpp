/*
	Easiest BFS problem that can be there. 
*/

#include <iostream>
#include <vector>
#include <queue>

using namespace std;

class Solution {
  public:
    vector<int> bfs(vector<vector<int>> &adj) {
			// code here
			int numNodes = adj.size();
			vector<bool> visited(numNodes, false);
			vector<int> ans;
			
			queue<int> q;
			q.push(0);
			visited[0] = true;

			while(!q.empty()) {
				int node = q.front();
				q.pop();

				ans.push_back(node);

				for(int neighbour:adj[node]) {
					if(!visited[neighbour]) {
						q.push(neighbour);
						visited[neighbour] = true;
					}
				}

			}			
			return ans;
    }
};

int main() {

    return 0;
}