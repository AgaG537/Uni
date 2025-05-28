#include <iostream>
#include "bst.h"
#include "sequence_generators.h"

void run_task1_scenario(int n, bool ascending_insert) {
    BST bst;
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
        bst.insert(key);
        bst.print_tree();
        std::cout << "Tree Height: " << bst.height() << std::endl;
        std::cout << "---------------------------" << std::endl;
    }

    std::cout << "\n--- DELETE OPERATIONS ---" << std::endl;
    for (int key : delete_sequence) {
        std::cout << "Operation: delete " << key << std::endl;
        bst.delete_value(key);
        bst.print_tree();
        std::cout << "Tree Height: " << bst.height() << std::endl;
        std::cout << "---------------------------" << std::endl;
    }
}

int main() {
    const int n_task1 = 10;

    // Scenario 1: Insert ascending sequence, delete random permutation
    run_task1_scenario(n_task1, true);

    // Scenario 2: Insert random permutation, delete random permutation
    run_task1_scenario(n_task1, false);

    return 0;
}