#ifndef BINOMIAL_HEAP_H
#define BINOMIAL_HEAP_H

#include <limits>
#include <queue>
#include <vector>

struct BinomialNode {
    int key;
    int degree;
    BinomialNode* parent;
    BinomialNode* child;
    BinomialNode* sibling;

    BinomialNode(int k) : key(k), degree(0), parent(nullptr), child(nullptr), sibling(nullptr) {}
};

class BinomialHeap {
public:
    BinomialHeap() : head(nullptr), comparisons(0) {}

    ~BinomialHeap() {
        if (head) {
            std::queue<BinomialNode*> q;
            BinomialNode* current_root = head;
            while (current_root) {
                q.push(current_root);
                current_root = current_root->sibling;
            }

            while (!q.empty()) {
                BinomialNode* node = q.front();
                q.pop();

                BinomialNode* child = node->child;
                while (child) {
                    q.push(child);
                    child = child->sibling;
                }
                delete node;
            }
            head = nullptr;
        }
    }

    long long getComparisons() const { return comparisons; }

    void insert(int key) {
        BinomialNode* node = new BinomialNode(key);
        BinomialHeap tmp;
        tmp.head = node;

        this->unionWith(tmp);
    }

    void unionWith(BinomialHeap& other) {
        BinomialNode* merged_list = mergeRootLists(this->head, other.head);
        
        this->head = nullptr; 
        other.head = nullptr;

        if (!merged_list) {
            return;
        }

        // Iterate through the merged list and link trees of equal degree
        BinomialNode* prev_x = nullptr;
        BinomialNode* x = merged_list;
        BinomialNode* next_x = x->sibling;

        while (x) {
            // Case 1: x is the last tree, or x's degree is different from next_x's degree
            // Case 2: x, next_x, and next_x->sibling all have the same degree
            if (!next_x || (x->degree != next_x->degree) ||
                (next_x->sibling && next_x->sibling->degree == x->degree)) {
                
                prev_x = x;
                x = next_x;
            } else {
                // Case 3: x and next_x have the same degree, and next_x->sibling has a different degree (or is null).
                // We must link x and next_x.
                
                // Compare keys and link the tree with the larger root as child of the smaller root
                comparisons++;
                if (x->key <= next_x->key) {
                    x->sibling = next_x->sibling;
                    linkTrees(next_x, x); // next_x becomes child of x
                } else {
                    if (prev_x) {
                        prev_x->sibling = next_x;
                    } else {
                        merged_list = next_x; // next_x becomes the new head of the root list
                    }
                    linkTrees(x, next_x); // x becomes child of next_x
                    x = next_x;
                }
            }
            // Update next_x for the next iteration
            next_x = x ? x->sibling : nullptr;
        }
        this->head = merged_list;
    }

    int extractMin() {
        if (!head) {
            return std::numeric_limits<int>::max();
        }

        BinomialNode* min_node = head;
        BinomialNode* prev_min = nullptr;
        BinomialNode* current = head->sibling;
        BinomialNode* prev_current = head;

        while (current) {
            comparisons++;
            if (current->key < min_node->key) {
                min_node = current;
                prev_min = prev_current;
            }
            prev_current = current;
            current = current->sibling;
        }

        if (prev_min) {
            prev_min->sibling = min_node->sibling;
        } else {
            head = min_node->sibling;
        }

        // Create a new heap from the children of min_node
        // For union operation, we need them in decreasing degree order (reversed).
        BinomialHeap children_heap;
        BinomialNode* child_list = min_node->child;
        
        BinomialNode* reversed_child_list = nullptr;
        while (child_list) {
            BinomialNode* next_child = child_list->sibling;
            child_list->sibling = reversed_child_list;
            child_list->parent = nullptr;
            reversed_child_list = child_list;
            child_list = next_child;
        }
        children_heap.head = reversed_child_list;

        // Delete the extracted min_node
        int extracted_key = min_node->key;
        delete min_node;

        // Merge the main heap with the new children heap
        this->unionWith(children_heap);
        
        return extracted_key;
    }

    bool isEmpty() const {
        return head == nullptr;
    }

private:
    BinomialNode* head;
    long long comparisons;

    // Links two binomial trees (y becomes child of z)
    void linkTrees(BinomialNode* y, BinomialNode* z) {
        y->parent = z;
        y->sibling = z->child;
        z->child = y;
        z->degree++;
    }

    // Merges two sorted lists of binomial tree roots (sorted by degree).
    static BinomialNode* mergeRootLists(BinomialNode* h1, BinomialNode* h2) {
        if (!h1) return h2;
        if (!h2) return h1;

        BinomialNode* result_head;
        BinomialNode* result_tail;

        // Initialize the merged list
        if (h1->degree <= h2->degree) {
            result_head = h1;
            h1 = h1->sibling;
        } else {
            result_head = h2;
            h2 = h2->sibling;
        }
        result_tail = result_head;

        // Merge the remaining nodes
        while (h1 && h2) {
            if (h1->degree <= h2->degree) {
                result_tail->sibling = h1;
                h1 = h1->sibling;
            } else {
                result_tail->sibling = h2;
                h2 = h2->sibling;
            }
            result_tail = result_tail->sibling;
        }
        // Append any remaining nodes
        result_tail->sibling = (h1 ? h1 : h2);
        return result_head;
    }
};

#endif // BINOMIAL_HEAP_H