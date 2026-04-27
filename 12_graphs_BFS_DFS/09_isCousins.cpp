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

    void solveDFS(Node *root, Node *parent, int level, 
        Node *&parentX, Node *&parentY, int &levelX, int &levelY,
        int x, int y) {
            if(!root) return;

            if(root->data == x) {
                levelX = level;
                parentX = parent;
            }

            if(root->data == y) {
                levelY = level;
                parentY = parent;
            }

           solveDFS(root->left, root, level + 1, parentX, parentY, levelX, levelY, x, y);
           solveDFS(root->right, root, level + 1, parentX, parentY, levelX, levelY, x, y);
        }

    bool isCousins(Node* root, int x, int y) {
        Node *parentX = nullptr, *parentY = nullptr;
        int levelX = 0, levelY = 0;

        solveDFS(root, NULL, 0, parentX, parentY, levelX, levelY, x, y);

        return (levelX == levelY && parentX != parentY);

        
    }
};

int main() {
    return 0;    
}