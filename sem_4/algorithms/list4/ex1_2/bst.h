#ifndef BST_H
#define BST_H

#include <string>
#include <vector>
#include <iostream>
#include <algorithm>
#include <stack>
#include <queue>
#include <utility>

struct Node {
    int key;
    Node* left;
    Node* right;
    Node* parent;

    Node(int k) : key(k), left(nullptr), right(nullptr), parent(nullptr) {}
};

class BST {
private:
    Node* root;

    Node* search(int key);
    Node* find_min(Node* node);
    void transplant(Node* u, Node* v);

public:
    long long comparisons;
    long long pointer_operations;

    BST();
    ~BST();

    void insert(int key);
    void delete_value(int key);
    int height();
    void print_tree();
    void print_tree_recursive(Node* node, const std::string& prefix, bool isLeft);
    void reset_metrics();
    void clear_tree();
};


BST::BST() : root(nullptr), comparisons(0), pointer_operations(0) {}

BST::~BST() {
    clear_tree();
}

void BST::reset_metrics() {
    comparisons = 0;
    pointer_operations = 0;
}

void BST::clear_tree() {
    if (root == nullptr) {
        return;
    }

    std::stack<Node*> s1;
    std::stack<Node*> s2;

    s1.push(root);

    while (!s1.empty()) {
        Node* current = s1.top();
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
        Node* current = s2.top();
        s2.pop();
        delete current;
    }
    root = nullptr;
}

void BST::insert(int key) {
    Node* new_node = new Node(key);
    pointer_operations++;

    if (root == nullptr) {
        root = new_node;
        return;
    }

    Node* current = root;
    Node* parent = nullptr;

    while (current != nullptr) {
        parent = current;
        comparisons++;
        if (key < current->key) {
            pointer_operations++;
            current = current->left;
        } else {
            pointer_operations++;
            current = current->right;
        }
    }

    new_node->parent = parent;
    pointer_operations++;

    if (key < parent->key) {
        pointer_operations++;
        parent->left = new_node;
    } else {
        pointer_operations++;
        parent->right = new_node;
    }
}

Node* BST::search(int key) {
    Node* current = root;
    while (current != nullptr) {
        comparisons++;
        if (key == current->key) {
            return current;
        } else if (key < current->key) {
            pointer_operations++;
            current = current->left;
        } else {
            pointer_operations++;
            current = current->right;
        }
    }
    return nullptr;
}

Node* BST::find_min(Node* node) {
    if (node == nullptr) {
        return nullptr;
    }
    Node* current = node;
    while (current->left != nullptr) {
        pointer_operations++;
        current = current->left;
    }
    return current;
}

void BST::transplant(Node* u, Node* v) {
    pointer_operations += 2;
    if (u->parent == nullptr) {
        root = v;
    } else if (u == u->parent->left) {
        u->parent->left = v;
    } else {
        u->parent->right = v;
    }
    if (v != nullptr) {
        pointer_operations++;
        v->parent = u->parent;
    }
}

void BST::delete_value(int key) {
    Node* node_to_delete = search(key);
    if (node_to_delete == nullptr) {
        return;
    }

    if (node_to_delete->left == nullptr) {
        pointer_operations++;
        transplant(node_to_delete, node_to_delete->right);
    } else if (node_to_delete->right == nullptr) {
        pointer_operations++;
        transplant(node_to_delete, node_to_delete->left);
    } else {
        Node* successor = find_min(node_to_delete->right);
        if (successor->parent != node_to_delete) {
            pointer_operations++;
            transplant(successor, successor->right);
            pointer_operations += 2;
            successor->right = node_to_delete->right;
            successor->right->parent = successor;
        }
        pointer_operations++;
        transplant(node_to_delete, successor);
        pointer_operations += 2;
        successor->left = node_to_delete->left;
        successor->left->parent = successor;
    }
    delete node_to_delete;
}

int BST::height() {
    if (root == nullptr) {
        return 0;
    }

    int h = 0;
    std::queue<Node*> q;
    q.push(root);
    q.push(nullptr);

    while (!q.empty()) {
        Node* current = q.front();
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
    return h;
}

void BST::print_tree_recursive(Node* node, const std::string& prefix, bool isLeft) {
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

void BST::print_tree() {
    if (root == nullptr) {
        std::cout << "Tree is empty." << std::endl;
        return;
    }
    print_tree_recursive(root, "", false);
}

#endif // BST_H