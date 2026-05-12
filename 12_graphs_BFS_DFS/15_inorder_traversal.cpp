/*
An inorder traversal first visits the left child (including its entire subtree), then visits the node, and finally visits the right child (including its entire subtree).
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

			ans.push_back(root->data);

			if(root->right) {
				traverse(root->right, ans);
			}

		}

    vector<int> inOrder(Node* root) {
      vector<int> ans;
			traverse(root, ans);
			return ans;
        
    }
};