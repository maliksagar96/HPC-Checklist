/*
    Find out if the level of 2 nodes is same or not.
*/
#include <iostream>

using namespace std;

struct Node {
    int data;
    Node *left;
    Node *right;

    Node(int val) {
        data = val;
        left = right = NULL;
    }
};

class Solution {
  public:
    // Function to check if two nodes are cousins in a tree
    int findLevel(Node *root, int x, int level) {
        if(!root) return -1;
        if(root->data == x) return level;

        int left = findLevel(root->left, x, level+1);
        if(left != -1) return left;

        return findLevel(root->right, x, level+1);
    }

    bool sameLevel(Node* root, int x, int y) {
        return findLevel(root, x, 0) == findLevel(root, y, 0);
    }
};

int main() {

    return 0;
}