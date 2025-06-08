#include <iostream>
#include <fstream>
#include <vector>
#include <random>
#include <chrono>
#include <iomanip>
#include <string>
#include <cassert>

#include "binomial_heap.h"

// ----- Experiment 1: For n = 500, record comparisons per operation for 5 trials -----
void singleExperiment(int n, const std::string& filename) {
    std::cout << "Running singleExperiment for n=" << n << " (5 trials).\n";
    std::ofstream file(filename + ".csv");
    if (!file.is_open()) {
        std::cerr << "Error: Could not open " << filename << ".csv for writing.\n";
        return;
    }
    file << "trial,operation_type,operation_index,comparisons\n";

    std::random_device rd;
    std::mt19937_64 rng(rd());
    std::uniform_int_distribution<int> dist(0, 10 * n);

    for (int trial_idx = 0; trial_idx < 5; ++trial_idx) {
        BinomialHeap H1, H2;

        // Insert n random elements into H1
        for (int i = 0; i < n; ++i) {
            long long current_H1_comparisons = H1.getComparisons();
            H1.insert(dist(rng));
            file << trial_idx + 1 << ",insert," << (i + 1) << "," << (H1.getComparisons() - current_H1_comparisons) << "\n";
        }

        // Insert n random elements into H2
        for (int i = 0; i < n; ++i) {
            long long current_H2_comparisons = H2.getComparisons();
            H2.insert(dist(rng));
            file << trial_idx + 1 << ",insert," << (i + 1) << "," << (H2.getComparisons() - current_H2_comparisons) << "\n";
        }

        // Union H1 and H2
        long long current_H1_comparisons_before_union = H1.getComparisons();
        H1.unionWith(H2); // H2 becomes empty, its nodes are merged into H1
        file << trial_idx + 1 << ",union," << 1 << "," << (H1.getComparisons() - current_H1_comparisons_before_union) << "\n";

        // Perform 2n Extract-Min operations on the merged heap (now in H1)
        std::vector<int> extracted_elements; // For verification
        for (int i = 0; i < 2 * n; ++i) {
            long long current_H1_comparisons_before_extract = H1.getComparisons();
            int minVal = H1.extractMin();
            extracted_elements.push_back(minVal);
            file << trial_idx + 1 << ",extractMin," << (i + 1) << "," << (H1.getComparisons() - current_H1_comparisons_before_extract) << "\n";
        }

        // Check if extracted elements are sorted
        for (size_t i = 1; i < extracted_elements.size(); ++i) {
            assert(extracted_elements[i - 1] <= extracted_elements[i]);
        }
        if (!H1.isEmpty()) {
            std::cerr << "Warning: H1 is not empty after all extractions in trial " << trial_idx + 1 << " for n=" << n << "\n";
        }
    }

    file.close();
    std::cout << "Results for singleExperiment saved to " << filename << ".csv\n";
}

// ----- Experiment 2: For n in {100, 200, ..., 10000}, calculate average comparisons per operation -----
void averagedExperiment(const std::string& filename) {
    std::cout << "\nRunning averagedExperiment for n from 100 to 10000.\n";
    std::ofstream out(filename + ".csv");
    if (!out.is_open()) {
        std::cerr << "Error: Could not open " << filename << ".csv for writing.\n";
        return;
    }
    out << "n,avg_comparison_per_op\n";

    std::random_device rd;
    std::mt19937_64 rng(rd());
    
    for (int n = 100; n <= 10000; n += 100) {
        std::uniform_int_distribution<int> dist(0, 10 * n);

        BinomialHeap H1, H2;

        // Insert n random elements into H1
        for (int i = 0; i < n; ++i) {
            H1.insert(dist(rng));
        }

        // Insert n random elements into H2
        for (int i = 0; i < n; ++i) {
            H2.insert(dist(rng));
        }

        // Union H1 and H2
        H1.unionWith(H2);

        // Perform 2n Extract-Min operations on the merged heap (now in H1)
        for (int i = 0; i < 2 * n; ++i) {
            H1.extractMin();
        }

        // H1.getComparisons() now holds all comparisons from its inserts, union, and extract-mins.
        // H2.getComparisons() holds all comparisons from its inserts (before it was merged into H1).
        long long total_comparisons_for_n = H1.getComparisons() + H2.getComparisons();

        // n inserts into H1 + n inserts into H2 + 1 union + 2n extract-mins
        long long total_ops_for_n = (long long)n + (long long)n + 1 + (long long)2 * n;

        double avg = static_cast<double>(total_comparisons_for_n) / total_ops_for_n;
        out << n << "," << std::fixed << std::setprecision(3) << avg << "\n";
    }

    out.close();
    std::cout << "Results for averagedExperiment saved to " << filename << ".csv\n";
}

int main() {
    // Experiments for n = 500, 5 trials
    singleExperiment(500, "exp_n500");

    // Experiments for n = 100, 200, ..., 10000
    averagedExperiment("avg_cost_by_n");

    return 0;
}