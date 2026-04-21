#pragma once 

#include <iostream>
#include <vector>
#include <filesystem>
#include <fstream>
#include <cmath>
#include <random>
#include <chrono>
#include <algorithm>
#include <climits>
#include <omp.h>
#include <atomic>
#include <functional>

#include "utils.hpp"

using namespace std;


pair<long long, int> localSearch(const vector<int>& distMatrix, vector<int>& solution){
    int noSteps = 0;
    long long currCost = calculateCost(distMatrix, solution);
    const int n = solution.size();

    for(;; noSteps++){
        long long bestDelta = 0;
        int newI = -1; int newJ = -1;

        for (int i = 0; i < n; i++) {
            int idx_prev_i = ((i - 1 + n) % n);
            int node_prev_i = solution[idx_prev_i];
            int node_i = solution[i];

            for (int j = i + 1; j < n; j++) {
                if (i == 0 && j == n - 1) continue;
                int next_j = (j + 1) % n;
                int node_j = solution[j];
                int node_next_j = solution[next_j];

                long long delta = -distMatrix[node_prev_i * n + node_i] 
                                  - distMatrix[node_j * n + node_next_j]
                                  + distMatrix[node_prev_i * n + node_j] 
                                  + distMatrix[node_i * n + node_next_j];

                if (delta < bestDelta) {
                    bestDelta = delta;
                    newI = i; newJ = j;
                }
            }
        }

        if(bestDelta >= 0) break;
        currCost += bestDelta;
        std::reverse(solution.begin() + newI, solution.begin() + newJ + 1);
    }
    return {currCost,noSteps};
}

pair<long long, int> localSearchFast(const vector<int>& distMatrix, vector<int>& solution){
    int noSteps = 0;
    long long currCost = calculateCost(distMatrix, solution);
    const int n = solution.size();

    mt19937 mt{};
    uniform_int_distribution randN{0, n-1};

    for(;; noSteps++){
        long long bestDelta = 0;
        int newI = -1; int newJ = -1;

        for (int k = 0; k < n; k++) {
            int i = randN(mt);
            int j = randN(mt);
            if(i == j || (i == 0 && j == n - 1)) continue;
            if(i > j) swap(i,j);

            int idx_prev_i = ((i - 1 + n) % n);
            int node_prev_i = solution[idx_prev_i];
            int node_i = solution[i];
            int next_j = (j + 1) % n;
            int node_j = solution[j];
            int node_next_j = solution[next_j];

            long long delta = -distMatrix[node_prev_i * n + node_i] 
                                - distMatrix[node_j * n + node_next_j]
                                + distMatrix[node_prev_i * n + node_j] 
                                + distMatrix[node_i * n + node_next_j];

            if (delta < bestDelta) {
                bestDelta = delta;
                newI = i; newJ = j;
            }
        }

        if(bestDelta >= 0) break;
        currCost += bestDelta;
        std::reverse(solution.begin() + newI, solution.begin() + newJ + 1);
    }
    return {currCost,noSteps};
}