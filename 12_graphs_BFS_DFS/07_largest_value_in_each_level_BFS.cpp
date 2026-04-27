/*
Find max in each level.
*/


#include <iostream>
#include <queue>
#include <vector>
#include <climits>
#include <algorithm>

using namespace std;

struct Node {
    public:
    Node *left;
    Node *right;
		int data;
};

class Solution {
	public:
    vector<int> largestValues(Node* root) {
      if (!root) return {};
      vector<int> ans;
      queue<Node*> q;
  	  q.push(root);

      while(!q.empty()) {
        
				int sz = q.size();
				int maxi = INT_MIN;

				//iterate over current level
        for(int i = 0;i<sz;i++) {
					Node *curr = q.front();
					q.pop();

					maxi = max(maxi, curr->data);
				//Push all the entries of a single level in a queue.
					if(curr->left) q.push(curr->left);
					if(curr->right) q.push(curr->right);
				}
				ans.push_back(maxi);
      }

    
      return ans;
    }
};

int main() {

    return 0;
}