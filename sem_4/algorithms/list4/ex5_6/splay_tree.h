#ifndef SPLAY_TREE_H
#define SPLAY_TREE_H

#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <stack>
#include <queue>
#include <utility>

struct SplayNode {
    int key;
    SplayNode* parent;
    SplayNode* left;
    SplayNode* right;

    SplayNode(int k) : key(k), parent(nullptr), left(nullptr), right(nullptr) {}
};

class SplayTree {
private:
    SplayNode* root;

    void rotate_left(SplayNode* x);
    void rotate_right(SplayNode* x);
    void splay(SplayNode* node);
    SplayNode* find_min(SplayNode* node);
    SplayNode* search_iterative_internal(int key);

public:
    long long comparisons;
    long long pointer_operations;
    
    SplayTree();
    ~SplayTree();

    void insert(int key);
    void delete_value(int key);
    SplayNode* search(int key);
    int height();
    void print_tree();
    void print_tree_recursive(SplayNode* node, const std::string& prefix, bool isLeft);
    void reset_metrics();
    void clear_tree();
};

SplayTree::SplayTree() : root(nullptr), comparisons(0), pointer_operations(0) {}

SplayTree::~SplayTree() {
    clear_tree();
}

void SplayTree::reset_metrics() {
    comparisons = 0;
    pointer_operations = 0;
}

void SplayTree::clear_tree() {
    if (root == nullptr) {
        return;
    }

    std::stack<SplayNode*> s1;
    std::stack<SplayNode*> s2;

    s1.push(root);

    while (!s1.empty()) {
        SplayNode* current = s1.top();
        s1.pop();
        s2.push(current);

        if (current->left) {
            s1.push(current->left);
        }
        if (current->right) {
            s1.push(current->right);
        }
    }

    while (!s2.empty()) {
        SplayNode* current = s2.top();
        s2.pop();
        delete current;
    }
    root = nullptr;
}

void SplayTree::rotate_left(SplayNode* x) {
    SplayNode* y = x->right;
    x->right = y->left;
    if (y->left != nullptr) {
        y->left->parent = x;
        pointer_operations++;
    }
    y->parent = x->parent;
    pointer_operations++;
    if (x->parent == nullptr) {
        root = y;
        pointer_operations++;
    } else if (x == x->parent->left) {
        x->parent->left = y;
        pointer_operations++;
    } else {
        x->parent->right = y;
        pointer_operations++;
    }
    y->left = x;
    x->parent = y;
    pointer_operations += 2;
}

void SplayTree::rotate_right(SplayNode* x) {
    SplayNode* y = x->left;
    x->left = y->right;
    if (y->right != nullptr) {
        y->right->parent = x;
        pointer_operations++;
    }
    y->parent = x->parent;
    pointer_operations++;
    if (x->parent == nullptr) {
        root = y;
        pointer_operations++;
    } else if (x == x->parent->right) {
        x->parent->right = y;
        pointer_operations++;
    } else {
        x->parent->left = y;
        pointer_operations++;
    }
    y->right = x;
    x->parent = y;
    pointer_operations += 2;
}

void SplayTree::splay(SplayNode* node) {
    if (node == nullptr) return;

    while (node->parent != nullptr) {
        pointer_operations++; // Check parent
        if (node->parent->parent == nullptr) { // Zig operation (node is child of root)
            pointer_operations++; // Check grandparent
            if (node == node->parent->left) { // Zig-Right
                rotate_right(node->parent);
            } else { // Zig-Left
                rotate_left(node->parent);
            }
        } else if (node == node->parent->left && node->parent == node->parent->parent->left) { // Zig-Zig (left-left)
            pointer_operations += 2; // Checks for left child and left grandparent child
            rotate_right(node->parent->parent); // Rotate grandparent
            rotate_right(node->parent);        // Rotate parent
        } else if (node == node->parent->right && node->parent == node->parent->parent->right) { // Zig-Zig (right-right)
            pointer_operations += 2; // Checks for right child and right grandparent child
            rotate_left(node->parent->parent); // Rotate grandparent
            rotate_left(node->parent);         // Rotate parent
        } else if (node == node->parent->right && node->parent == node->parent->parent->left) { // Zig-Zag (left-right)
            pointer_operations += 2; // Checks for right child and left grandparent child
            rotate_left(node->parent); // Rotate parent (makes node left child)
            rotate_right(node->parent); // Rotate grandparent (now node's new parent)
        } else { // Zag-Zig (right-left)
            pointer_operations += 2; // Checks for left child and right grandparent child
            rotate_right(node->parent); // Rotate parent (makes node right child)
            rotate_left(node->parent); // Rotate grandparent (now node's new parent)
        }
    }
    root = node;
    pointer_operations++;
}

SplayNode* SplayTree::search_iterative_internal(int key) {
    SplayNode* current = root;
    SplayNode* last_visited = nullptr;

    while (current != nullptr) {
        last_visited = current;
        comparisons++;
        if (key == current->key) {
            return current;
        } else if (key < current->key) {
            current = current->left;
            pointer_operations++;
        } else {
            current = current->right;
            pointer_operations++;
        }
    }
    return last_visited;
}

SplayNode* SplayTree::search(int key) {
    SplayNode* node_to_splay = search_iterative_internal(key);

    if (node_to_splay != nullptr) {
        splay(node_to_splay);
        if (root->key == key) {
            comparisons++;
            return root;
        }
    }
    return nullptr;
}


void SplayTree::insert(int key) {
    SplayNode* new_node = new SplayNode(key);
    pointer_operations++;

    if (root == nullptr) {
        root = new_node;
        return;
    }

    SplayNode* current = root;
    SplayNode* parent = nullptr;
    bool found_existing = false;

    while (current != nullptr) {
        parent = current;
        comparisons++;
        if (key < current->key) {
            current = current->left;
            pointer_operations++;
        } else if (key > current->key) {
            current = current->right;
            pointer_operations++;
        } else {
            found_existing = true;
            break;
        }
    }

    if (found_existing) {
        delete new_node;
        splay(parent);
        return;
    }

    new_node->parent = parent;
    pointer_operations++;

    comparisons++;
    if (key < parent->key) {
        parent->left = new_node;
        pointer_operations++;
    } else {
        parent->right = new_node;
        pointer_operations++;
    }

    splay(new_node);
}

SplayNode* SplayTree::find_min(SplayNode* node) {
    if (node == nullptr) {
        return nullptr;
    }
    SplayNode* current = node;
    while (current->left != nullptr) {
        pointer_operations++;
        current = current->left;
    }
    return current;
}

void SplayTree::delete_value(int key) {
    SplayNode* node_to_delete = search(key);

    if (node_to_delete == nullptr || node_to_delete->key != key) {
        return;
    }

    SplayNode* left_subtree = node_to_delete->left;
    SplayNode* right_subtree = node_to_delete->right;
    pointer_operations += 2;

    if (left_subtree != nullptr) {
        left_subtree->parent = nullptr;
        pointer_operations++;
    }
    if (right_subtree != nullptr) {
        right_subtree->parent = nullptr;
        pointer_operations++;
    }

    delete node_to_delete;
    pointer_operations++;

    if (left_subtree == nullptr) {
        root = right_subtree;
    } else if (right_subtree == nullptr) {
        root = left_subtree;
    } else {
        
        SplayNode* new_root_candidate = left_subtree;
        while (new_root_candidate->right != nullptr) {
            new_root_candidate = new_root_candidate->right;
            pointer_operations++;
        }
        splay(new_root_candidate);

        root->right = right_subtree;
        if (right_subtree != nullptr) {
            right_subtree->parent = root;
            pointer_operations++;
        }
        pointer_operations++;
    }
}

int SplayTree::height() {
    if (root == nullptr) {
        return 0;
    }

    int h = 0;
    std::queue<SplayNode*> q;
    q.push(root);
    q.push(nullptr);

    while (!q.empty()) {
        SplayNode* current = q.front();
        q.pop();

        if (current == nullptr) {
            if (!q.empty()) {
                h++;
                q.push(nullptr);
            }
        } else {
            if (current->left) {
                q.push(current->left);
            }
            if (current->right) {
                q.push(current->right);
            }
        }
    }
    return h + 1;
}

void SplayTree::print_tree_recursive(SplayNode* node, const std::string& prefix, bool isLeft) {
    if (node != nullptr) {
        std::cout << prefix;
        if (node == root) {
            std::cout << "+---";
        } else {
            std::cout << (isLeft ? "+L--" : "+R--");
        }

        std::cout << '[' << node->key << ']' << std::endl;

        print_tree_recursive(node->left, prefix + (isLeft ? "|     " : "      "), true);
        print_tree_recursive(node->right, prefix + (isLeft ? "|     " : "      "), false);
    }
}

void SplayTree::print_tree() {
    if (root == nullptr) {
        std::cout << "Tree is empty." << std::endl;
        return;
    }
    print_tree_recursive(root, "", false);
}

#endif // SPLAY_TREE_H