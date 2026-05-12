#include <iostream>
#include <queue>

using namespace std;

class Node {
  public:
    int data;
    Node* left;
    Node* right;

    // Constructor
    Node(int val) {
			data = val;
			left = nullptr;
			right = nullptr;
    }
};


class Solution {
  public:
    vector<int> levelOrder(Node *root) {
      
			queue<Node*> q;
      vector<int> ans; 
			q.push(root);
			
			while(!q.empty()) {

				Node *currentNode = q.front();
				q.pop();
				ans.push_back(currentNode->data);
				if(currentNode->left) q.push(currentNode->left);
				if(currentNode->right) q.push(currentNode->right);
			}
			return ans;
    }
};


int main() {

    return 0;
}