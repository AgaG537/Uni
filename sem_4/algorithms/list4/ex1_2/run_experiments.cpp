#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <numeric>
#include <algorithm>
#include <random>

#include "bst.h"
#include "sequence_generators.h"

struct AggregatedMetrics {
    double avg_comparisons;
    long long max_comparisons;
    double avg_pointer_operations;
    long long max_pointer_operations;
    double avg_height;
    int max_height;
};

AggregatedMetrics run_tests_and_aggregate(int n, bool ascending_insert, int num_tests) {
    std::vector<long long> all_comparisons;
    std::vector<long long> all_pointer_ops;
    std::vector<int> all_heights;

    for (int test = 0; test < num_tests; ++test) {
        BST bst;
        std::vector<int> insert_sequence;
        std::vector<int> delete_sequence = generate_random_permutation(n);

        if (ascending_insert) {
            insert_sequence = generate_ascending_sequence(n);
        } else {
            insert_sequence = generate_random_permutation(n);
        }

        for (int key : insert_sequence) {
            bst.reset_metrics();
            bst.insert(key);
            all_comparisons.push_back(bst.comparisons);
            all_pointer_ops.push_back(bst.pointer_operations);
            all_heights.push_back(bst.height());
        }

        for (int key : delete_sequence) {
            bst.reset_metrics();
            bst.delete_value(key);
            all_comparisons.push_back(bst.comparisons);
            all_pointer_ops.push_back(bst.pointer_operations);
            all_heights.push_back(bst.height());
        }
        bst.clear_tree();
    }

    AggregatedMetrics results;
    results.avg_comparisons = static_cast<double>(std::accumulate(all_comparisons.begin(), all_comparisons.end(), 0LL)) / all_comparisons.size();
    results.max_comparisons = *std::max_element(all_comparisons.begin(), all_comparisons.end());
    results.avg_pointer_operations = static_cast<double>(std::accumulate(all_pointer_ops.begin(), all_pointer_ops.end(), 0LL)) / all_pointer_ops.size();
    results.max_pointer_operations = *std::max_element(all_pointer_ops.begin(), all_pointer_ops.end());
    results.avg_height = static_cast<double>(std::accumulate(all_heights.begin(), all_heights.end(), 0LL)) / all_heights.size();
    results.max_height = *std::max_element(all_heights.begin(), all_heights.end());

    return results;
}

int main() {
    const int num_tests_per_n = 5;
    const int start_n = 10000;
    const int end_n = 100000;
    const int step_n = 10000;

    std::ofstream output_file("experiment_results.csv");
    if (!output_file.is_open()) {
        std::cerr << "Error: Could not open experiment_results.csv" << std::endl;
        return 1;
    }
    output_file << "n,scenario,metric,avg_cost,max_cost\n";

    for (int n = start_n; n <= end_n; n += step_n) {
        std::cout << "C++: Running experiments for n = " << n << std::endl;

        // Scenario 1: Insert ascending sequence, delete random permutation
        AggregatedMetrics s1_results = run_tests_and_aggregate(n, true, num_tests_per_n);
        output_file << n << ",ascending_test,key_comparisons," << s1_results.avg_comparisons << "," << s1_results.max_comparisons << "\n";
        output_file << n << ",ascending_test,pointer_operations," << s1_results.avg_pointer_operations << "," << s1_results.max_pointer_operations << "\n";
        output_file << n << ",ascending_test,tree_height," << s1_results.avg_height << "," << s1_results.max_height << "\n";

        // Scenario 2: Insert random permutation, delete random permutation
        AggregatedMetrics s2_results = run_tests_and_aggregate(n, false, num_tests_per_n);
        output_file << n << ",random_test,key_comparisons," << s2_results.avg_comparisons << "," << s2_results.max_comparisons << "\n";
        output_file << n << ",random_test,pointer_operations," << s2_results.avg_pointer_operations << "," << s2_results.max_pointer_operations << "\n";
        output_file << n << ",random_test,tree_height," << s2_results.avg_height << "," << s2_results.max_height << "\n";
    }

    output_file.close();
    std::cout << "C++: Experiments completed. Results saved to experiment_results.csv" << std::endl;

    return 0;
}
