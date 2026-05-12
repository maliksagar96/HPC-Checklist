/*
	A postorder traversal first visits the left child (including its entire subtree), then visits the right child (including its entire subtree), and finally visits the node itself.
*/

#include <iostream>
#include <vector>

using namespace std;

class Node {
  public:
    int data;
    Node* left;
    Node* right;

    Node(int val) {
			data = val;
			left = NULL;
			right = NULL;
    }
};


class Solution {
  public:

	void traverse(Node *root, vector<int>& ans) {
		if(!root) return;

		if(root->left) {
			traverse(root->left, ans);
		}

		if(root->right) {
			traverse(root->right, ans);
		}

		ans.push_back(root->data);

	}

	vector<int> postOrder(Node* root) {
		vector<int> ans;
		traverse(root, ans);
		return ans;		
	}
};

int main() {

    return 0;
}