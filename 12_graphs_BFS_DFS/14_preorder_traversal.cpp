#include <iostream>
#include <vector>

using namespace std;


class Node
{
	int data;
	Node* left;
	Node* right;

	Node(int x){
			data = x;
			left = right = NULL;
	}
};


class Solution {
  public:

		void traverse(Node *root, vector<int> &ans) {
			if(!root) return ;
			ans.push_back(root->data);

			if(root->left) {
				traverse(root->left, ans);
			}
			if(root->right) {
				traverse(root->right, ans);
			}
		}
		
    vector<int> preOrder(Node* root) {
			// code here
			vector<int> ans;
			traverse(root, ans);
			return ans;
        
    }
};

int main() {

    return 0;
}

