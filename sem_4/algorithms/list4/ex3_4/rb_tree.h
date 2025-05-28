#ifndef RB_TREE_H
#define RB_TREE_H

#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <stack>
#include <queue>
#include <utility>

enum Color { RED, BLACK };

struct RBNode {
    int key;
    Color color;
    RBNode* parent;
    RBNode* left;
    RBNode* right;

    RBNode(int k) : key(k), color(RED), parent(nullptr), left(nullptr), right(nullptr) {}
};

class RBTree {
private:
    RBNode* root;
    RBNode* nil;

    void left_rotate(RBNode* x);
    void right_rotate(RBNode* y);
    void insert_fixup(RBNode* z);
    void transplant(RBNode* u, RBNode* v);
    void delete_fixup(RBNode* x);
    RBNode* find_min(RBNode* node);
    RBNode* search_node(int key);
    void delete_node(RBNode* z);

public:
    long long comparisons;
    long long pointer_operations;

    RBTree();
    ~RBTree();

    void insert(int key);
    void delete_value(int key);
    int height();
    void print_tree();
    void print_tree_recursive(RBNode* node, const std::string& prefix, bool isLeft);
    void reset_metrics();
    void clear_tree();
};

RBTree::RBTree() {
    nil = new RBNode(0);
    nil->color = BLACK;
    nil->left = nil;
    nil->right = nil;
    nil->parent = nil;

    root = nil;
    comparisons = 0;
    pointer_operations = 0;
}

RBTree::~RBTree() {
    clear_tree();
    delete nil;
}

void RBTree::reset_metrics() {
    comparisons = 0;
    pointer_operations = 0;
}

void RBTree::clear_tree() {
    if (root == nil) {
        return;
    }

    std::stack<RBNode*> s1;
    std::stack<RBNode*> s2;

    s1.push(root);

    while (!s1.empty()) {
        RBNode* current = s1.top();
        s1.pop();
        s2.push(current);

        if (current->left != nil) {
            s1.push(current->left);
        }
        if (current->right != nil) {
            s1.push(current->right);
        }
    }

    while (!s2.empty()) {
        RBNode* current = s2.top();
        s2.pop();
        delete current;
    }
    root = nil;
}

void RBTree::left_rotate(RBNode* x) {
    RBNode* y = x->right;
    x->right = y->left;
    if (y->left != nil) {
        y->left->parent = x;
        pointer_operations++;
    }
    y->parent = x->parent;
    pointer_operations++;
    if (x->parent == nil) {
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

void RBTree::right_rotate(RBNode* y) {
    RBNode* x = y->left;
    y->left = x->right;
    if (x->right != nil) {
        x->right->parent = y;
        pointer_operations++;
    }
    x->parent = y->parent;
    pointer_operations++;
    if (y->parent == nil) {
        root = x;
        pointer_operations++;
    } else if (y == y->parent->right) {
        y->parent->right = x;
        pointer_operations++;
    } else {
        y->parent->left = x;
        pointer_operations++;
    }
    x->right = y;
    y->parent = x;
    pointer_operations += 2;
}

void RBTree::insert(int key) {
    RBNode* z = new RBNode(key);
    pointer_operations++;
    z->left = nil;
    z->right = nil;
    z->color = RED;

    RBNode* y = nil;
    RBNode* x = root;

    while (x != nil) {
        y = x;
        comparisons++;
        if (z->key < x->key) {
            x = x->left;
            pointer_operations++;
        } else {
            x = x->right;
            pointer_operations++;
        }
    }
    z->parent = y;
    pointer_operations++;

    if (y == nil) {
        root = z;
        pointer_operations++;
    } else {
        comparisons++;
        if (z->key < y->key) {
            y->left = z;
            pointer_operations++;
        } else {
            y->right = z;
            pointer_operations++;
        }
    }
    insert_fixup(z);
}

void RBTree::insert_fixup(RBNode* z) {
    while (z->parent->color == RED) {
        comparisons++; // Color comparison
        if (z->parent == z->parent->parent->left) {
            RBNode* y = z->parent->parent->right; // Uncle
            pointer_operations++;
            if (y->color == RED) { // Case 1: Uncle is RED
                z->parent->color = BLACK;
                y->color = BLACK;
                z->parent->parent->color = RED;
                z = z->parent->parent;
                pointer_operations += 3;
            } else { // Case 2 or 3
                comparisons++;
                if (z == z->parent->right) { // Case 2: z is right child
                    z = z->parent;
                    left_rotate(z);
                }
                // Case 3: z is left child
                z->parent->color = BLACK;
                z->parent->parent->color = RED;
                right_rotate(z->parent->parent);
                pointer_operations += 2;
            }
        } else {
            RBNode* y = z->parent->parent->left; // Uncle
            pointer_operations++;
            if (y->color == RED) { // Case 1: Uncle is RED
                z->parent->color = BLACK;
                y->color = BLACK;
                z->parent->parent->color = RED;
                z = z->parent->parent;
                pointer_operations += 3;
            } else { // Case 2 or 3
                comparisons++;
                if (z == z->parent->left) { // Case 2: z is left child
                    z = z->parent;
                    right_rotate(z);
                }
                // Case 3: z is right child
                z->parent->color = BLACK;
                z->parent->parent->color = RED;
                left_rotate(z->parent->parent);
                pointer_operations += 2;
            }
        }
    }
    root->color = BLACK;
    pointer_operations++;
}

void RBTree::transplant(RBNode* u, RBNode* v) {
    pointer_operations += 2;
    if (u->parent == nil) {
        root = v;
    } else if (u == u->parent->left) {
        u->parent->left = v;
    } else {
        u->parent->right = v;
    }
    v->parent = u->parent;
    pointer_operations++;
}

RBNode* RBTree::find_min(RBNode* node) {
    while (node->left != nil) {
        node = node->left;
        pointer_operations++;
    }
    return node;
}

RBNode* RBTree::search_node(int key) {
    RBNode* current = root;
    while (current != nil && key != current->key) {
        comparisons++;
        if (key < current->key) {
            current = current->left;
            pointer_operations++;
        } else {
            current = current->right;
            pointer_operations++;
        }
    }
    comparisons++;
    return current;
}

void RBTree::delete_node(RBNode* z) {
    RBNode* y = z;
    RBNode* x;
    Color y_original_color = y->color;
    pointer_operations++;

    if (z->left == nil) {
        x = z->right;
        transplant(z, z->right);
        pointer_operations++;
    } else if (z->right == nil) {
        x = z->left;
        transplant(z, z->left);
        pointer_operations++;
    } else {
        y = find_min(z->right);
        y_original_color = y->color;
        x = y->right;
        pointer_operations += 2;

        if (y->parent == z) {
            x->parent = y;
            pointer_operations++;
        } else {
            transplant(y, y->right);
            y->right = z->right;
            y->right->parent = y;
            pointer_operations += 2;
        }
        transplant(z, y);
        y->left = z->left;
        y->left->parent = y;
        y->color = z->color;
        pointer_operations += 3;
    }
    delete z;
    pointer_operations++;

    if (y_original_color == BLACK) {
        delete_fixup(x);
    }
}

void RBTree::delete_value(int key) {
    RBNode* node_to_delete = search_node(key);
    if (node_to_delete != nil) {
        delete_node(node_to_delete);
    }
}

void RBTree::delete_fixup(RBNode* x) {
    while (x != root && x->color == BLACK) {
        comparisons++;
        if (x == x->parent->left) {
            RBNode* w = x->parent->right; // Sibling
            pointer_operations++;
            comparisons++;
            if (w->color == RED) { // Case 1: Sibling is RED
                w->color = BLACK;
                x->parent->color = RED;
                left_rotate(x->parent);
                w = x->parent->right;
                pointer_operations += 3;
            }
            comparisons += 2;
            if (w->left->color == BLACK && w->right->color == BLACK) { // Case 2: Sibling is BLACK, both children BLACK
                w->color = RED;
                x = x->parent;
                pointer_operations += 2;
            } else { // Case 3 or 4
                comparisons++;
                if (w->right->color == BLACK) { // Case 3: Sibling is BLACK, left child RED, right child BLACK
                    w->left->color = BLACK;
                    w->color = RED;
                    right_rotate(w);
                    w = x->parent->right;
                    pointer_operations += 3;
                }
                // Case 4: Sibling is BLACK, right child RED
                w->color = x->parent->color;
                x->parent->color = BLACK;
                w->right->color = BLACK;
                left_rotate(x->parent);
                x = root; // Terminate loop
                pointer_operations += 4;
            }
        } else {
            RBNode* w = x->parent->left; // Sibling
            pointer_operations++;
            comparisons++;
            if (w->color == RED) { // Case 1: Sibling is RED
                w->color = BLACK;
                x->parent->color = RED;
                right_rotate(x->parent);
                w = x->parent->left;
                pointer_operations += 3;
            }
            comparisons += 2;
            if (w->right->color == BLACK && w->left->color == BLACK) { // Case 2: Sibling is BLACK, both children BLACK
                w->color = RED;
                x = x->parent;
                pointer_operations += 2;
            } else { // Case 3 or 4
                comparisons++;
                if (w->left->color == BLACK) { // Case 3: Sibling is BLACK, right child RED, left child BLACK
                    w->right->color = BLACK;
                    w->color = RED;
                    left_rotate(w);
                    w = x->parent->left;
                    pointer_operations += 3;
                }
                // Case 4: Sibling is BLACK, left child RED
                w->color = x->parent->color;
                x->parent->color = BLACK;
                w->left->color = BLACK;
                right_rotate(x->parent);
                x = root; // Terminate loop
                pointer_operations += 4;
            }
        }
    }
    x->color = BLACK;
    pointer_operations++;
}

int RBTree::height() {
    if (root == nil) {
        return 0;
    }

    int h = 0;
    std::queue<RBNode*> q;
    q.push(root);
    q.push(nullptr);

    while (!q.empty()) {
        RBNode* current = q.front();
        q.pop();

        if (current == nullptr) {
            if (!q.empty()) {
                h++;
                q.push(nullptr);
            }
        } else {
            if (current->left != nil) {
                q.push(current->left);
            }
            if (current->right != nil) {
                q.push(current->right);
            }
        }
    }
    return h;
}

void RBTree::print_tree_recursive(RBNode* node, const std::string& prefix, bool isLeft) {
    if (node != nil) {
        std::cout << prefix;
        if (node == root) {
            std::cout << "+---";
        } else {
            std::cout << (isLeft ? "+L--" : "+R--");
        }
        
        std::cout << '[' << node->key << "] (" << (node->color == RED ? "RED" : "BLACK") << ")" << std::endl;

        print_tree_recursive(node->left, prefix + (isLeft ? "|     " : "      "), true);
        print_tree_recursive(node->right, prefix + (isLeft ? "|     " : "      "), false);
    }
}

void RBTree::print_tree() {
    if (root == nil) {
        std::cout << "Tree is empty." << std::endl;
        return;
    }
    print_tree_recursive(root, "", false);
}

#endif // RB_TREE_H