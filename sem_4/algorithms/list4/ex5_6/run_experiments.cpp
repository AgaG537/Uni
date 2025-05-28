#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include <numeric>
#include <algorithm>
#include <random>
#include <omp.h>
#include <map>

#include "splay_tree.h"
#include "sequence_generators.h"

struct AggregatedMetrics {
    double avg_comparisons;
    long long max_comparisons;
    double avg_pointer_operations;
    long long max_pointer_operations;
    double avg_height;
    int max_height;
};

AggregatedMetrics run_tests_and_aggregate(int n_val, bool ascending_insert, int num_tests) {
    std::vector<long long> all_comparisons;
    std::vector<long long> all_pointer_ops;
    std::vector<int> all_heights;

    for (int test = 0; test < num_tests; ++test) {
        SplayTree splayTree;
        std::vector<int> insert_sequence;
        std::vector<int> delete_sequence = generate_random_permutation(n_val);

        if (ascending_insert) {
            insert_sequence = generate_ascending_sequence(n_val);
        } else {
            insert_sequence = generate_random_permutation(n_val);
        }

        for (int key : insert_sequence) {
            splayTree.reset_metrics();
            splayTree.insert(key);
            all_comparisons.push_back(splayTree.comparisons);
            all_pointer_ops.push_back(splayTree.pointer_operations);
            all_heights.push_back(splayTree.height());
        }

        for (int key : delete_sequence) {
            splayTree.reset_metrics();
            splayTree.delete_value(key);
            all_comparisons.push_back(splayTree.comparisons);
            all_pointer_ops.push_back(splayTree.pointer_operations);
            all_heights.push_back(splayTree.height());
        }
        splayTree.clear_tree();
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

    std::map<int, std::vector<std::string>> ordered_results;
    omp_lock_t map_lock;
    omp_init_lock(&map_lock);

    int n;

    #pragma omp parallel for default(none) \
        shared(start_n, end_n, step_n, num_tests_per_n, ordered_results, map_lock, std::cout, std::cerr) \
        private(n)

    for (n = start_n; n <= end_n; n += step_n) {
        #pragma omp critical(cout_output)
        {
            std::cout << "C++: Thread " << omp_get_thread_num() << " STARTING experiments for n = " << n << "\n";
        }

        AggregatedMetrics s1_results = run_tests_and_aggregate(n, true, num_tests_per_n);
        std::string s1_comp_line = std::to_string(n) + ",ascending_test,key_comparisons," + std::to_string(s1_results.avg_comparisons) + "," + std::to_string(s1_results.max_comparisons) + "\n";
        std::string s1_ptr_line = std::to_string(n) + ",ascending_test,pointer_operations," + std::to_string(s1_results.avg_pointer_operations) + "," + std::to_string(s1_results.max_pointer_operations) + "\n";
        std::string s1_height_line = std::to_string(n) + ",ascending_test,tree_height," + std::to_string(s1_results.avg_height) + "," + std::to_string(s1_results.max_height) + "\n";

        AggregatedMetrics s2_results = run_tests_and_aggregate(n, false, num_tests_per_n);
        std::string s2_comp_line = std::to_string(n) + ",random_test,key_comparisons," + std::to_string(s2_results.avg_comparisons) + "," + std::to_string(s2_results.max_comparisons) + "\n";
        std::string s2_ptr_line = std::to_string(n) + ",random_test,pointer_operations," + std::to_string(s2_results.avg_pointer_operations) + "," + std::to_string(s2_results.max_pointer_operations) + "\n";
        std::string s2_height_line = std::to_string(n) + ",random_test,tree_height," + std::to_string(s2_results.avg_height) + "," + std::to_string(s2_results.max_height) + "\n";
        
        #pragma omp critical(cout_output)
        {
            std::cout << "C++: Thread " << omp_get_thread_num() << " finished calculations for n = " << n << ". ATTEMPTING to acquire map_lock.\n";
        }

        omp_set_lock(&map_lock);
        try {
            #pragma omp critical(cout_output)
            {
                std::cout << "C++: Thread " << omp_get_thread_num() << " ACQUIRED map_lock for n = " << n << ". Adding results.\n";
            }
            ordered_results[n].push_back(s1_comp_line);
            ordered_results[n].push_back(s1_ptr_line);
            ordered_results[n].push_back(s1_height_line);
            ordered_results[n].push_back(s2_comp_line);
            ordered_results[n].push_back(s2_ptr_line);
            ordered_results[n].push_back(s2_height_line);
            
            #pragma omp critical(cout_output)
            {
                std::cout << "C++: Thread " << omp_get_thread_num() << " FINISHED adding results for n = " << n << ". Releasing map_lock.\n";
            }
        } catch (const std::exception& e) {
            #pragma omp critical(cout_output)
            {
                std::cerr << "C++: Thread " << omp_get_thread_num() << " CAUGHT EXCEPTION in map_lock section for n = " << n << ": " << e.what() << "\n";
            }
            omp_unset_lock(&map_lock);
            throw;
        } catch (...) {
            #pragma omp critical(cout_output)
            {
                std::cerr << "C++: Thread " << omp_get_thread_num() << " CAUGHT UNKNOWN EXCEPTION in map_lock section for n = " << n << "\n";
            }
            omp_unset_lock(&map_lock);
            throw;
        }
        omp_unset_lock(&map_lock);

        #pragma omp critical(cout_output)
        {
            std::cout << "C++: Thread " << omp_get_thread_num() << " COMPLETED iteration for n = " << n << "\n";
        }
    }

    std::cout << "C++: All parallel iterations have completed. Attempting to destroy map_lock.\n";
    omp_destroy_lock(&map_lock);
    std::cout << "C++: map_lock destroyed. Proceeding to write results to file.\n";

    for (auto const& [n_val, lines] : ordered_results) {
        for (const std::string& line : lines) {
            output_file << line;
        }
    }

    output_file.close();
    std::cout << "C++: Experiments completed. Results saved to experiment_results.csv" << std::endl;

    return 0;
}