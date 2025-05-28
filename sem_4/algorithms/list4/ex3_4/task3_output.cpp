#include <iostream>
#include "rb_tree.h"
#include "sequence_generators.h"

void run_task3_scenario(int n, bool ascending_insert) {
    RBTree rb_tree;
    std::vector<int> insert_sequence;
    std::vector<int> delete_sequence = generate_random_permutation(n);

    if (ascending_insert) {
        std::cout << "--- Scenario 1: Inserting an ascending sequence, deleting a random permutation ---" << std::endl;
        insert_sequence = generate_ascending_sequence(n);
    } else {
        std::cout << "--- Scenario 2: Inserting a random permutation, deleting a random permutation ---" << std::endl;
        insert_sequence = generate_random_permutation(n);
    }

    std::cout << "\n--- INSERT OPERATIONS ---" << std::endl;
    for (int key : insert_sequence) {
        std::cout << "Operation: insert " << key << std::endl;
        rb_tree.insert(key);
        rb_tree.print_tree();
        std::cout << "Tree Height: " << rb_tree.height() << std::endl;
        std::cout << "---------------------------" << std::endl;
    }

    std::cout << "\n--- DELETE OPERATIONS ---" << std::endl;
    for (int key : delete_sequence) {
        std::cout << "Operation: delete " << key << std::endl;
        rb_tree.delete_value(key);
        rb_tree.print_tree();
        std::cout << "Tree Height: " << rb_tree.height() << std::endl;
        std::cout << "---------------------------" << std::endl;
    }
}

int main() {
    const int n_task3 = 30;

    // Scenario 1: Insert ascending sequence, delete random permutation
    run_task3_scenario(n_task3, true);

    // Scenario 2: Insert random permutation, delete random permutation
    run_task3_scenario(n_task3, false);

    return 0;
}