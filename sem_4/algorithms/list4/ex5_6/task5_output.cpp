#include <iostream>
#include "splay_tree.h"
#include "sequence_generators.h"

void run_task5_scenario(int n, bool ascending_insert) {
    SplayTree splay_tree;
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
        splay_tree.insert(key);
        splay_tree.print_tree();
        std::cout << "Tree Height: " << splay_tree.height() << std::endl;
        std::cout << "---------------------------" << std::endl;
    }

    std::cout << "\n--- DELETE OPERATIONS ---" << std::endl;
    for (int key : delete_sequence) {
        std::cout << "Operation: delete " << key << std::endl;
        splay_tree.delete_value(key);
        splay_tree.print_tree();
        std::cout << "Tree Height: " << splay_tree.height() << std::endl;
        std::cout << "---------------------------" << std::endl;
    }
}

int main() {
    const int n_task5 = 30;

    // Scenario 1: Insert ascending sequence, delete random permutation
    run_task5_scenario(n_task5, true);

    // Scenario 2: Insert random permutation, delete random permutation
    run_task5_scenario(n_task5, false);

    return 0;
}