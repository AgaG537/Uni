#include <iostream>
#include <vector>
#include <chrono>
#include <fstream>
#include <random>

int comparisons = 0;

bool binary_search_recursive(const std::vector<int>& arr, int low, int high, int v) {
    if (low > high) return false;
    comparisons++;
    int mid = low + (high - low) / 2;
    if (arr[mid] == v) return true;
    comparisons++;
    if (arr[mid] > v)
        return binary_search_recursive(arr, low, mid - 1, v);
    else
        return binary_search_recursive(arr, mid + 1, high, v);
}

int search(const std::vector<int>& arr, int v) {
    comparisons = 0;
    bool found = binary_search_recursive(arr, 0, arr.size() - 1, v);
    return found ? 1 : 0;
}

int main() {
    std::ofstream out("results.csv");
    out << "n,scenario,comparisons,time_microsec\n";
    std::mt19937 rng(42);

    std::vector<std::string> scenarios = {"beginning", "middle", "end", "absent", "random"};

    for (int n = 1000; n <= 100000; n += 1000) {
        std::vector<int> arr(n);
        for (int i = 0; i < n; ++i) arr[i] = i;

        for (const std::string& scenario : scenarios) {
            int v;
            if (scenario == "beginning") v = 0;
            else if (scenario == "middle") v = n / 2;
            else if (scenario == "end") v = n - 1;
            else if (scenario == "absent") v = n + 10;
            else {
                std::uniform_int_distribution<int> dist(0, n - 1);
                v = arr[dist(rng)];
            }

            auto start = std::chrono::high_resolution_clock::now();
            for (int i = 0; i < 1000; ++i)
                search(arr, v);
            auto end = std::chrono::high_resolution_clock::now();

            double elapsed_us = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count() / 1000.0;

            out << n << "," << scenario << "," << comparisons << "," << elapsed_us << "\n";
        }
    }

    out.close();
    return 0;
}
