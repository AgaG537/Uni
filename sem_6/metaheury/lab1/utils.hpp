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

using namespace std;


void readFile(const std::filesystem::directory_entry& entry, vector<pair<double, double>>& coordinates){
    cout << entry << "\n";
    if(entry.path().extension() == ".tsp"){
        ifstream file(entry.path());
        if(file.is_open()){
            string line;
            while(getline(file, line)){
                if(line.find("NODE_COORD_SECTION") != string::npos) break;
            }

            int id;
            double x, y;
            while(file >> id >> x >> y){
                coordinates.push_back({x,y});
            }
            file.close();
        }
    }
}

int EUC_2Dnorm(const pair<double, double>& a, const pair<double, double>& b){
    return static_cast<int>(std::round(std::hypot(a.first - b.first, a.second - b.second)));
}

vector<int> createDistanceMatrix(vector<pair<double, double>>& coordinates){
    int n = coordinates.size();
    vector<int> dist(n * n);
    for(int i = 0; i < n; i++){
        for(int j = 0; j < n; j++){
            dist[i * n + j] = EUC_2Dnorm(coordinates[i], coordinates[j]);
        }
    }
    return dist;
}

vector<int> randomPermutation(int n){
    vector<int> perm(n);
    for(int i = 0; i < n; i++) perm[i] = i;
    random_device rd;
    mt19937 g(rd());
    shuffle(perm.begin(), perm.end(), g);
    return perm;
}

long long calculateCost(const vector<int>& distMatrix, const vector<int>& perm){
    long long cost = 0;
    const int n = perm.size();
    for(int i = 0; i < n-1; i++)
        cost += distMatrix[perm[i] * n + perm[i+1]];
    cost += distMatrix[perm[n-1] * n + perm[0]];
    return cost;
}

long long primMst(const vector<int>& distMatrix, int n, vector<vector<int>>& tree) {
    tree.assign(n, vector<int>());

    vector<bool> inTree(n, false);
    vector<int> minDist(n, numeric_limits<int>::max());
    vector<int> parent(n, -1);

    minDist[0] = 0;
    long long weight = 0;

    for (int step = 0; step < n; ++step) {
        int bestDist = numeric_limits<int>::max();
        int u = -1;
        
        for (int i = 0; i < n; ++i) {
            if (!inTree[i] && minDist[i] < bestDist) {
                bestDist = minDist[i];
                u = i;
            }
        }

        inTree[u] = true;

        if (parent[u] != -1) {
            tree[u].push_back(parent[u]);
            tree[parent[u]].push_back(u);
            weight += bestDist;
        }

        for (int v = 0; v < n; ++v) {
            if (!inTree[v]) {
                int dist = distMatrix[u * n + v];
                
                if (dist < minDist[v]) {
                    minDist[v] = dist;
                    parent[v] = u;
                }
            }
        }
    }

    return weight;
}

void DFS(int start, const vector<vector<int>>& tree, vector<bool>& visited, vector<int>& tour) {
    visited[start] = true;
    tour.push_back(start);
    for (int neighbor : tree[start]) {
        if (!visited[neighbor]) {
            DFS(neighbor, tree, visited, tour);
        }
    }
}