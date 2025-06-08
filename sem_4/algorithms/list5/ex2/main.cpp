#include <iostream>
#include <vector>
#include <random>
#include <chrono>
#include <algorithm>
#include <queue>
#include <limits>

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

std::vector<Edge> kruskalMSTEdges(int n, std::vector<Edge> all_edges) {
    std::vector<Edge> mst_edges;
    if (n <= 1) return mst_edges;

    std::sort(all_edges.begin(), all_edges.end());

    DisjointSet ds(n);
    int edgesCount = 0;

    for (const auto& edge : all_edges) {
        if (ds.find(edge.u) != ds.find(edge.v)) {
            ds.unite(edge.u, edge.v);
            mst_edges.push_back(edge);
            edgesCount++;
            if (edgesCount == n - 1) {
                break;
            }
        }
    }
    return mst_edges;
}

void generateCompleteGraphEdges(int n, std::vector<Edge>& edges) {
    edges.clear();
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<> dis(0.0, 1.0);

    for (int i = 0; i < n; ++i) {
        for (int j = i + 1; j < n; ++j) {
            double weight = dis(gen);
            edges.push_back({i, j, weight});
        }
    }
}

// ----- New structures for the Optimal Information Propagation -----

struct TreeNode {
    int id;
    int parent_id;
    std::vector<int> children_ids;
    std::vector<int> optimal_child_order;
    // Minimum time to inform the entire subtree rooted at this node
    double T_val; 

    TreeNode(int _id) : id(_id), parent_id(-1), T_val(0.0) {}
};

std::vector<TreeNode> tree_nodes;
std::vector<std::vector<int>> adj_list;

void buildRootedTree(int n, const std::vector<Edge>& mst_edges, int root_node_id) {
    tree_nodes.clear();
    tree_nodes.reserve(n);
    for (int i = 0; i < n; ++i) {
        tree_nodes.emplace_back(i);
    }

    adj_list.assign(n, std::vector<int>());
    for (const auto& edge : mst_edges) {
        adj_list[edge.u].push_back(edge.v);
        adj_list[edge.v].push_back(edge.u);
    }

    std::queue<int> q;
    std::vector<bool> visited(n, false);

    q.push(root_node_id);
    visited[root_node_id] = true;
    tree_nodes[root_node_id].parent_id = -1;

    while (!q.empty()) {
        int u = q.front();
        q.pop();

        for (int v : adj_list[u]) {
            if (!visited[v]) {
                visited[v] = true;
                tree_nodes[u].children_ids.push_back(v);
                tree_nodes[v].parent_id = u;
                q.push(v);
            }
        }
    }
}

double computeOptimalTimes(int u_id) {
    TreeNode& u = tree_nodes[u_id];

    if (u.children_ids.empty()) {
        u.T_val = 0;
        return u.T_val;
    }

    // Recursively compute T_val for all children
    std::vector<std::pair<double, int>> children_T_vals;
    for (int child_id : u.children_ids) {
        double child_T = computeOptimalTimes(child_id);
        children_T_vals.push_back({child_T, child_id});
    }

    // Sort children in descending order of their T_val
    std::sort(children_T_vals.rbegin(), children_T_vals.rend());

    u.optimal_child_order.clear();
    double max_time_from_u = 0.0;

    for (size_t j = 0; j < children_T_vals.size(); ++j) {
        int child_id = children_T_vals[j].second;
        u.optimal_child_order.push_back(child_id);

        // Total time for j-th child's subtree to be fully informed is (j + 1) + its T_val
        double current_child_subtree_total_time = (j + 1) + children_T_vals[j].first;
        
        if (current_child_subtree_total_time > max_time_from_u) {
            max_time_from_u = current_child_subtree_total_time;
        }
    }
    u.T_val = max_time_from_u;
    return u.T_val;
}

int simulatePropagation(int root_node_id) {
    std::vector<int> time_received(tree_nodes.size(), -1); 

    time_received[root_node_id] = 0;
    std::queue<int> q;
    q.push(root_node_id);

    int max_rounds_achieved = 0;

    while (!q.empty()) {
        int u_id = q.front();
        q.pop();
        const TreeNode& u = tree_nodes[u_id];

        if (time_received[u_id] > max_rounds_achieved) {
            max_rounds_achieved = time_received[u_id];
        }

        // Propagate info to children according to the optimal order
        for (size_t j = 0; j < u.optimal_child_order.size(); ++j) {
            int child_id = u.optimal_child_order[j];
            int child_receive_time = time_received[u_id] + (j + 1); 
            
            if (time_received[child_id] == -1 || child_receive_time < time_received[child_id]) {
                time_received[child_id] = child_receive_time;
                q.push(child_id);
            }
        }
    }
    return max_rounds_achieved;
}


int main() {

    int nMin = 1000;
    int nMax = 10000;
    int step = 1000;
    int repetitions = 20;

    std::random_device rd_main;
    std::mt19937 gen_main(rd_main());

    std::cout << "n,AvgRounds,MinRounds,MaxRounds" << std::endl;

    for (int n = nMin; n <= nMax; n += step) {
        long long total_rounds = 0;
        int min_rounds_overall = std::numeric_limits<int>::max();
        int max_rounds_overall = std::numeric_limits<int>::min();

        for (int r = 0; r < repetitions; ++r) {
            std::vector<Edge> complete_graph_edges;
            generateCompleteGraphEdges(n, complete_graph_edges);
            std::vector<Edge> mst_edges = kruskalMSTEdges(n, complete_graph_edges);

            if (mst_edges.size() != n - 1 && n > 1) {
                std::cerr << "Error: MST for n=" << n << " has " << mst_edges.size() << " edges, expected " << n - 1 << std::endl;
                continue; 
            }
            if (n <= 1) {
                total_rounds += 0; 
                min_rounds_overall = std::min(min_rounds_overall, 0);
                max_rounds_overall = std::max(max_rounds_overall, 0);
                continue;
            }

            std::uniform_int_distribution<> dis_root(0, n - 1);
            int random_root = dis_root(gen_main);

            buildRootedTree(n, mst_edges, random_root);

            computeOptimalTimes(random_root);

            int current_rounds = simulatePropagation(random_root);

            total_rounds += current_rounds;
            if (current_rounds < min_rounds_overall) {
                min_rounds_overall = current_rounds;
            }
            if (current_rounds > max_rounds_overall) {
                max_rounds_overall = current_rounds;
            }
        }

        double avg_rounds = static_cast<double>(total_rounds) / repetitions;

        std::cout << n << "," << avg_rounds << "," << min_rounds_overall << "," << max_rounds_overall << std::endl;
    }

    return 0;
}