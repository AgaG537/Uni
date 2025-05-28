#ifndef SEQUENCE_GENERATORS_H
#define SEQUENCE_GENERATORS_H

#include <vector>
#include <random>
#include <algorithm>
#include <chrono>

std::vector<int> generate_ascending_sequence(int n) {
    std::vector<int> sequence(n);
    for (int i = 0; i < n; ++i) {
        sequence[i] = i + 1;
    }
    return sequence;
}

std::vector<int> generate_random_permutation(int n) {
    std::vector<int> sequence(n);
    for (int i = 0; i < n; ++i) {
        sequence[i] = i + 1;
    }
    unsigned seed = std::chrono::high_resolution_clock::now().time_since_epoch().count();
    std::shuffle(sequence.begin(), sequence.end(), std::mt19937(seed));
    return sequence;
}

#endif // SEQUENCE_GENERATORS_H