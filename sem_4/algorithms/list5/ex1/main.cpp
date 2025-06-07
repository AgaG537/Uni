#include <iostream>
#include <vector>
#include <random>
#include <chrono>
#include <algorithm>
#include <queue>
#include <limits>
#include <cmath>

struct Edge {
    int u, v;
    double weight;

    bool operator<(const Edge& other) const {
        return weight < other.weight;
    }
};

// Union-Find data structure (for Kruskal's)
class DisjointSet {
public:
    std::vector<int> parent;
    DisjointSet(int n) {
        parent.resize(n);
        for (int i = 0; i < n; ++i) {
            parent[i] = i;
        }
    }

    // Find the representative (root) of the set containing element i
    int find(int i) {
        if (parent[i] == i)
            return i;
        return parent[i] = find(parent[i]);
    }

    // Unite (merge) the sets containing elements i and j
    void unite(int i, int j) {
        int root_i = find(i);
        int root_j = find(j);
        if (root_i != root_j) {
            parent[root_i] = root_j;
        }
    }
};

struct MSTResult {
    double weight;
    long long complexityOperations;
};

void generateCompleteGraph(int n, std::vector<std::vector<double>>& adjMatrix, std::vector<Edge>& edges) {
    adjMatrix.assign(n, std::vector<double>(n, 0.0));
    edges.clear();

    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<> dis(0.0, 1.0);

    for (int i = 0; i < n; ++i) {
        for (int j = i + 1; j < n; ++j) {
            double weight = dis(gen);
            adjMatrix[i][j] = weight;
            adjMatrix[j][i] = weight;
            edges.push_back({i, j, weight});
        }
    }
}

MSTResult primMST(int n, const std::vector<std::vector<double>>& adjMatrix) {
    if (n == 0) return {0.0, 0LL};

    double mstWeight = 0.0;
    long long complexityOperations = 0LL;

    std::vector<double> minWeight(n, std::numeric_limits<double>::max());
    std::vector<bool> inMST(n, false);

    // Priority queue stores pairs of {weight, vertex}
    std::priority_queue<std::pair<double, int>, std::vector<std::pair<double, int>>, std::greater<std::pair<double, int>>> pq;

    minWeight[0] = 0.0; // Start with vertex 0
    pq.push({0.0, 0});
    complexityOperations++;

    while (!pq.empty()) {
        int u = pq.top().second;
        pq.pop();
        complexityOperations++;

        if (inMST[u]) continue;

        inMST[u] = true;
        mstWeight += minWeight[u];

        // Explore neighbors of u
        for (int v = 0; v < n; ++v) {
            complexityOperations++;
            if (adjMatrix[u][v] > 0 && !inMST[v]) {
                // If this edge is lighter than current minWeight[v]
                if (adjMatrix[u][v] < minWeight[v]) {
                    minWeight[v] = adjMatrix[u][v];
                    pq.push({minWeight[v], v});
                    complexityOperations++;
                }
            }
        }
    }
    return {mstWeight, complexityOperations};
}

MSTResult kruskalMST(int n, std::vector<Edge> edges) {
    if (n == 0) return {0.0, 0LL};

    double mstWeight = 0.0;
    long long complexityOperations = 0LL;

    // Sorting complexity: E log E
    long long numEdges = edges.size();
    if (numEdges > 1) {
        complexityOperations += numEdges * static_cast<long long>(std::log2(numEdges));
    }
    std::sort(edges.begin(), edges.end()); 

    DisjointSet ds(n);
    int edgesInMSTCount = 0;

    for (const auto& edge : edges) {
        // If adding this edge does not form a cycle
        if (ds.find(edge.u) != ds.find(edge.v)) {
            ds.unite(edge.u, edge.v);
            mstWeight += edge.weight;
            edgesInMSTCount++;
            complexityOperations += 2;
            if (edgesInMSTCount == n - 1) {
                break;
            }
        }
    }
    return {mstWeight, complexityOperations};
}

int main() {

    int nMin = 1000;
    int nMax = 10000;
    int step = 1000;
    int repetitions = 10;

    std::cout << "n,AvgTimePrim,AvgTimeKruskal,AvgPrimOperations,AvgKruskalOperations" << std::endl;

    for (int n = nMin; n <= nMax; n += step) {
        long long totalTimePrim = 0;
        long long totalTimeKruskal = 0;
        long long totalPrimOperations = 0;
        long long totalKruskalOperations = 0;

        for (int r = 0; r < repetitions; ++r) {
            std::vector<std::vector<double>> adjMatrix;
            std::vector<Edge> edges;

            generateCompleteGraph(n, adjMatrix, edges);

            auto startPrim = std::chrono::high_resolution_clock::now();
            MSTResult primResult = primMST(n, adjMatrix);
            auto endPrim = std::chrono::high_resolution_clock::now();
            totalTimePrim += std::chrono::duration_cast<std::chrono::microseconds>(endPrim - startPrim).count();
            totalPrimOperations += primResult.complexityOperations;

            auto startKruskal = std::chrono::high_resolution_clock::now();
            MSTResult kruskalResult = kruskalMST(n, edges);
            auto endKruskal = std::chrono::high_resolution_clock::now();
            totalTimeKruskal += std::chrono::duration_cast<std::chrono::microseconds>(endKruskal - startKruskal).count();
            totalKruskalOperations += kruskalResult.complexityOperations;
        }

        double avgTimePrim = static_cast<double>(totalTimePrim) / repetitions;
        double avgTimeKruskal = static_cast<double>(totalTimeKruskal) / repetitions;
        double avgPrimOperations = static_cast<double>(totalPrimOperations) / repetitions;
        double avgKruskalOperations = static_cast<double>(totalKruskalOperations) / repetitions;


        std::cout << n << "," << avgTimePrim << "," << avgTimeKruskal << ","
                  << avgPrimOperations << "," << avgKruskalOperations << std::endl;
    }

    return 0;
}