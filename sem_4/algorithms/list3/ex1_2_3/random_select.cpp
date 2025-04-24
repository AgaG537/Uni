#include <iostream>
#include <vector>
#include <algorithm>
#include <random>

using namespace std;

int comparisons = 0;
int swaps = 0;
bool verbose = true;

int compare(int a, int b) {
    comparisons++;
    return a - b;
}

void doSwap(int& a, int& b) {
    swaps++;
    std::swap(a, b);
}

void printArray(const vector<int>& A, const string& label) {
    if (verbose) {
        cout << label << ": ";
        for (int x : A) cout << x << " ";
        cout << endl;
    }
}

int partition(vector<int>& A, int left, int right, mt19937& rng) {
    uniform_int_distribution<int> dist(left, right);
    int pivotIndex = dist(rng);
    doSwap(A[pivotIndex], A[right]);
    int pivot = A[right];
    int i = left - 1;

    for (int j = left; j < right; ++j) {
        if (compare(A[j], pivot) <= 0) {
            i++;
            doSwap(A[i], A[j]);
        }
    }
    doSwap(A[i + 1], A[right]);
    return i + 1;
}

int randomizedSelect(vector<int>& A, int left, int right, int k, mt19937& rng) {
    if (left == right) return A[left];

    int q = partition(A, left, right, rng);
    int i = q - left + 1;

    if (A.size() <= 30) printArray(A, "After partition");

    if (k == i) return A[q];
    else if (k < i) return randomizedSelect(A, left, q - 1, k, rng);
    else return randomizedSelect(A, q + 1, right, k - i, rng);
}

int main(int argc, char* argv[]) {
    int n, k;
    cin >> n;

    if (argc < 2) {
        cerr << "Usage: ./randomized_select k [--silent]" << endl;
        return 1;
    }

    k = stoi(argv[1]);
    if (argc >= 3 && string(argv[2]) == "--silent") {
        verbose = false;
    }

    vector<int> A(n);
    for (int i = 0; i < n; i++) cin >> A[i];

    vector<int> original = A;

    random_device rd;
    mt19937 rng(rd());

    int result = randomizedSelect(A, 0, n - 1, k, rng);

    if (verbose) {
        cout << "\nOriginal array: ";
        for (int x : original) cout << x << " ";
        cout << "\nFinal array:    ";
        for (int x : A) cout << x << " ";

        sort(original.begin(), original.end());
        cout << "\nSorted array:   ";
        for (int x : original) cout << x << " ";

        cout << "\nSelected element (k = " << k << "): " << result << endl;
        cout << "Check: sorted[k-1] = " << original[k - 1] << endl;
        cout << "Comparisons: " << comparisons << ", Swaps: " << swaps << endl;
    } else {
        cout << comparisons << "," << swaps << endl;
    }

    return 0;
}
