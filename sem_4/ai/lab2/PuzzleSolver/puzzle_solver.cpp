#include <bits/stdc++.h>
using namespace std;

struct PuzzleState {
    vector<int> tiles;
    int blank;
    bool operator==(const PuzzleState &other) const {
        return tiles == other.tiles;
    }
};

struct PuzzleStateHash {
    size_t operator()(const PuzzleState &s) const {
        // Modified FNV-1a hash combining tile values
        uint64_t h = 1469598103934665603ULL;
        for (int x : s.tiles) {
            h ^= (uint64_t)x + 0x9e3779b97f4a7c15ULL + (h << 6) + (h >> 2);
        }
        return (size_t)h;
    }
};

int N;
vector<int> goal_positions;
vector<int> init_positions;

// --- Heuristics ---
int manhattan(const PuzzleState &s, const vector<int> &target_pos) {
    int dist = 0;
    for (int i = 0; i < N * N; i++) {
        int val = s.tiles[i];
        if (val != 0) {
            int goalIdx = target_pos[val];
            int row1 = i / N, col1 = i % N;
            int row2 = goalIdx / N, col2 = goalIdx % N;
            dist += abs(row1 - row2) + abs(col1 - col2);
        }
    }
    return dist;
}

int linearConflict(const PuzzleState &s, const vector<int> &target_pos) {
    int h = manhattan(s, target_pos);
    int conflicts = 0;

    // Row conflicts
    for (int row = 0; row < N; row++) {
        vector<pair<int, int>> rowTiles; // (col, tileValue)
        int rowStart = row * N;
        for (int col = 0; col < N; col++) {
            int idx = rowStart + col;
            int val = s.tiles[idx];
            if (val != 0) {
                int goalIdx = target_pos[val];
                int goalRow = goalIdx / N;
                if (goalRow == row) {
                    rowTiles.emplace_back(col, val);
                }
            }
        }
        for (int i = 0; i < (int)rowTiles.size(); i++) {
            int val_i = rowTiles[i].second;
            int goalCol_i = target_pos[val_i] % N;
            for (int j = i + 1; j < (int)rowTiles.size(); j++) {
                int val_j = rowTiles[j].second;
                int goalCol_j = target_pos[val_j] % N;
                if (goalCol_i > goalCol_j)
                    conflicts++;
            }
        }
    }

    // Column conflicts
    for (int col = 0; col < N; col++) {
        vector<pair<int, int>> colTiles; // (row, tileValue)
        for (int row = 0; row < N; row++) {
            int idx = row * N + col;
            int val = s.tiles[idx];
            if (val != 0) {
                int goalIdx = target_pos[val];
                int goalCol = goalIdx % N;
                if (goalCol == col) {
                    colTiles.emplace_back(row, val);
                }
            }
        }
        for (int i = 0; i < (int)colTiles.size(); i++) {
            int val_i = colTiles[i].second;
            int goalRow_i = target_pos[val_i] / N;
            for (int j = i + 1; j < (int)colTiles.size(); j++) {
                int val_j = colTiles[j].second;
                int goalRow_j = target_pos[val_j] / N;
                if (goalRow_i > goalRow_j)
                    conflicts++;
            }
        }
    }

    return h + 2 * conflicts; // each conflict adds 2 moves
}

int heuristic(const PuzzleState &s, const vector<int> &target_pos, string heuristicType) {
    if (heuristicType == "manhattan")
        return manhattan(s, target_pos);
    return linearConflict(s, target_pos);
}

// --- Helper functions ---
bool isSolvable(const std::vector<int> &tiles) {
    int inv = 0;
    int blank_row = 0;
    for (int i = 0; i < tiles.size(); i++) {
        if (tiles[i] == 0) {
            blank_row = i / N;
        }
        for (int j = i + 1; j < tiles.size(); ++j) {
            if (tiles[i] != 0 && tiles[j] != 0 && tiles[i] > tiles[j]) {
                inv++;
            }
        }
    }
    if (N % 2 == 1)
        return inv % 2 == 0;
    return (inv + blank_row) % 2 == 1;
}

void printState(const PuzzleState &s) {
    for (int i = 0; i < N * N; i++) {
        if (i % N == 0 && i > 0)
            cout << "\n";
        if (s.tiles[i] == 0) {
            if (N == 4)
                cout << "   ";
            else
                cout << "  ";
        }
        else {
            if (s.tiles[i] < 10)
                cout << " ";
            cout << s.tiles[i];
        }
        if (i % N < N - 1)
            cout << " ";
    }
    cout << "\n";
}

void printSolution(const vector<PuzzleState> &fullPath,
                   long long generated_count, long long visited_count,
                   double solve_time_ms, bool quietMode, string heurType) {
    if (!quietMode) {
        cout << "Moves:\n";
        for (size_t i = 0; i + 1 < fullPath.size(); i++) {
            const PuzzleState &cur = fullPath[i];
            const PuzzleState &nxt = fullPath[i + 1];
            int blankCur = cur.blank;
            int blankNxt = nxt.blank;

            int movedPos = blankNxt;
            int movedTile = cur.tiles[movedPos];
            int row1 = movedPos / N, col1 = movedPos % N;
            int row2 = blankCur / N, col2 = blankCur % N;
            string dir;
            if (row1 == row2) {
                dir = (col1 < col2 ? "right" : "left");
            }
            else {
                dir = (row1 < row2 ? "down" : "up");
            }
            cout << "Move tile " << movedTile << " " << dir << "\n";
        }

        cout << "\nNumber of moves: " << (fullPath.size() - 1) << "\n\n";
        cout << "Total generated states: " << generated_count << "\n";
        cout << "Total visited states: " << visited_count << "\n";
        cout << "Time: " << solve_time_ms << "\n";
        cout << "Heuristic: " << heurType << "\n";
    }
    else {
        cout << (fullPath.size() - 1) << " " << generated_count << " " 
             << visited_count << " " << solve_time_ms << " " << heurType << "\n";
    }
}

// --- Priority queue node and operator ---
struct Node {
    PuzzleState state;
    int g, f;
};

struct CompareNode {
    bool operator()(const Node &a, const Node &b) const {
        return a.f > b.f; // min-heap based on f = g + h
    }
};

// --- Parsing cmd arguments and initializing puzzle ---
PuzzleState initializePuzzle(int argc, char **argv, string &heur, bool &quietMode) {
    quietMode = false;
    for (int i = 1; i < argc; ++i) {
        if (string(argv[i]) == "--quiet") {
            quietMode = true;
            for (int j = i; j < argc - 1; ++j) {
                argv[j] = argv[j + 1];
            }
            argc--;
            break;
        }
    }

    if (argc < 3) {
        cout << "Usage: " << argv[0] << " N heuristic(manhattan/linearConflict) [--quiet] [tile1 tile2 ... tileN^2]\n";
        exit(0);
    }
    N = stoi(argv[1]);
    heur = argv[2];
    if (N <= 1) {
        cout << "Dimension N must be > 1.\n";
        exit(0);
    }
    if (!(heur == "manhattan" || heur == "linearConflict")) {
        cout << "Wrong heuristic type. Type 'manhattan' or 'linearConflict'";
        exit(0);
    }
    int total = N * N;
    PuzzleState initState;
    initState.tiles.resize(total);

    bool customState = (argc == 3 + total);
    if (customState) {
        for (int i = 0; i < total; i++) {
            int val = stoi(argv[3 + i]);
            if (val < 0 || val >= total) {
                cout << "Invalid tile value: " << val << "\n";
                exit(0);
            }
            initState.tiles[i] = val;
            if (val == 0)
                initState.blank = i;
        }
        if (!isSolvable(initState.tiles)) {
            cout << "Puzzle not solvable.";
            exit(0);
        }
        return initState;
    }
    else {
        vector<int> base(total);
        for (int i = 0; i < total - 1; i++)
            base[i] = i + 1;
        base[total - 1] = 0;
        initState.tiles = base;
        initState.blank = total - 1;
        unsigned seed = std::chrono::system_clock::now().time_since_epoch().count();
        std::mt19937 generator(seed);
        do {
            for (int i = total - 2; i > 0; i--) {
                std::uniform_int_distribution<int> distribution(0, i);
                int j = distribution(generator);
                swap(initState.tiles[i], initState.tiles[j]);
            }
            initState.tiles[total - 1] = 0;
        } while (!isSolvable(initState.tiles));
        initState.blank = total - 1;
    }
    return initState;
}

// --- Setting up goal state and position mappings ---
PuzzleState setupGoalState(const PuzzleState &initState) {
    int total = N * N;
    PuzzleState goalState;
    goalState.tiles.resize(total);
    for (int i = 0; i < total - 1; i++)
        goalState.tiles[i] = i + 1;
    goalState.tiles[total - 1] = 0;
    goalState.blank = total - 1;

    goal_positions.resize(total + 1);
    init_positions.resize(total + 1);
    for (int i = 0; i < total; i++) {
        goal_positions[goalState.tiles[i]] = i;
        init_positions[initState.tiles[i]] = i;
    }
    return goalState;
}

// --- bidirectional A* search ---
int solvePuzzle(const PuzzleState &initState, const PuzzleState &goalState, string heur,
                vector<PuzzleState> &fullPath,
                long long &generated_count, long long &visited_count) {

    unordered_map<PuzzleState, pair<int, PuzzleState>, PuzzleStateHash> visitedF, visitedB; // value: g, parent
    priority_queue<Node, vector<Node>, CompareNode> openF, openB;

    visitedF.reserve(1000000);
    visitedB.reserve(1000000);

    int h0 = heuristic(initState, goal_positions, heur);
    openF.push({initState, 0, h0});
    visitedF[initState] = {0, initState};

    int h1 = heuristic(goalState, init_positions, heur);
    openB.push({goalState, 0, h1});
    visitedB[goalState] = {0, goalState};

    int bestCost = INT_MAX;
    PuzzleState meetState;

    while (!openF.empty() && !openB.empty()) {
        if (openF.top().f + openB.top().f >= bestCost)
            break;

        if (openF.top().f <= openB.top().f) { // Expand from forward search
            Node node = openF.top();
            openF.pop();
            PuzzleState s = node.state;
            int g = node.g;

            if (g > visitedF[s].first)
                continue;

            // Check for meeting point
            auto itB = visitedB.find(s);
            if (itB != visitedB.end()) {
                int totalCost = g + itB->second.first;
                if (totalCost < bestCost) {
                    bestCost = totalCost;
                    meetState = s;
                }
            }

            // Expand neighbors
            int blankRow = s.blank / N, blankCol = s.blank % N;
            const int deltaRow[4] = {-1, 1, 0, 0};
            const int deltaCol[4] = {0, 0, -1, 1};

            for (int d = 0; d < 4; d++) {
                int newRow = blankRow + deltaRow[d], newCol = blankCol + deltaCol[d];
                if (newRow < 0 || newRow >= N || newCol < 0 || newCol >= N)
                    continue;

                PuzzleState t = s;
                int pos = newRow * N + newCol;
                swap(t.tiles[s.blank], t.tiles[pos]);
                t.blank = pos;
                int g2 = g + 1;

                auto itN = visitedF.find(t);
                if (itN == visitedF.end() || g2 < itN->second.first) { // If new state or shorter path found
                    generated_count++;
                    visitedF[t] = {g2, s}; // Store path and parent
                    int h2 = heuristic(t, goal_positions, heur);
                    openF.push({t, g2, g2 + h2});
                }
            }
            visited_count++;
        }
        else { // Expand from backward search
            Node node = openB.top();
            openB.pop();
            PuzzleState s = node.state;
            int g = node.g;

            auto itB = visitedB.find(s);
            if (itB == visitedB.end() || g > itB->second.first)
                continue;

            // Check for meeting point
            auto itF = visitedF.find(s);
            if (itF != visitedF.end()) {
                int totalCost = g + itF->second.first;
                if (totalCost < bestCost) {
                    bestCost = totalCost;
                    meetState = s;
                }
            }

            // Expand neighbors
            int br = s.blank / N, bc = s.blank % N;
            const int dr[4] = {-1, 1, 0, 0};
            const int dc[4] = {0, 0, -1, 1};

            for (int d = 0; d < 4; d++) {
                int nr = br + dr[d], nc = bc + dc[d];
                if (nr < 0 || nr >= N || nc < 0 || nc >= N)
                    continue;

                PuzzleState t = s;
                int pos = nr * N + nc;
                swap(t.tiles[s.blank], t.tiles[pos]);
                t.blank = pos;
                int g2 = g + 1;

                auto itN = visitedB.find(t);
                if (itN == visitedB.end() || g2 < itN->second.first) { // If new state or shorter path found
                    generated_count++;
                    visitedB[t] = {g2, s}; // Store path and parent
                    int h2 = heuristic(t, init_positions, heur);
                    openB.push({t, g2, g2 + h2});
                }
            }
            visited_count++;
        }
    }

    if (bestCost == INT_MAX) {
        return -1; // No solution found
    }

    // Reconstruct path
    vector<PuzzleState> pathF, pathB;
    for (PuzzleState cur = meetState;;) {
        pathF.push_back(cur);
        auto it = visitedF[cur];
        if (cur.tiles == it.second.tiles)
            break;
        cur = it.second;
    }
    reverse(pathF.begin(), pathF.end());

    {
        PuzzleState cur = meetState;
        while (true)
        {
            auto it = visitedB[cur];
            if (cur.tiles == it.second.tiles)
                break;
            cur = it.second;
            pathB.push_back(cur);
        }
    }

    for (auto &st : pathF)
        fullPath.push_back(st);

    for (size_t i = 0; i < pathB.size(); i++)
        fullPath.push_back(pathB[i]);

    return bestCost;
}

int main(int argc, char **argv) {
    string heur;
    bool quietMode;
    PuzzleState initState = initializePuzzle(argc, argv, heur, quietMode);
    PuzzleState goalState = setupGoalState(initState);

    if (!quietMode) {
        cout << "Initial puzzle state:\n";
        printState(initState);
        cout << "\n";
    }

    auto start_time = std::chrono::high_resolution_clock::now();

    long long generated_count = 0;
    long long visited_count = 0;
    vector<PuzzleState> fullPath;

    int bestCost = solvePuzzle(initState, goalState, heur, fullPath, generated_count, visited_count);

    auto end_time = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double, std::milli> solve_time_ms = end_time - start_time;

    if (bestCost == -1) {
        if (!quietMode) {
            cout << "No solution found.\n";
        }
        else {
            cout << "-1 -1 -1 -1\n";
        }
        return 0;
    }

    printSolution(fullPath, generated_count, visited_count, solve_time_ms.count(), quietMode, heur);

    return 0;
}