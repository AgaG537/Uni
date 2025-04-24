#include <iostream>
#include <vector>
#include <algorithm>
#include <random>

using namespace std;

int comparisons = 0;
int swaps = 0;
bool verbose = true;
int groupSize = 5;
int arraySize;

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

int partition(vector<int>& A, int left, int right, int pivot) {
    for (int i = left; i <= right; ++i) {
        if (A[i] == pivot) {
            doSwap(A[i], A[right]);
            break;
        }
    }

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

int medianOfMedians(vector<int>& A, int left, int right);

int select(vector<int>& A, int left, int right, int k) {
    if (left == right) return A[left];

    int pivot = medianOfMedians(A, left, right);
    int q = partition(A, left, right, pivot);
    int i = q - left + 1;

    if (arraySize <= 30) printArray(A, "After partition");

    if (k == i) return A[q];
    else if (k < i) return select(A, left, q - 1, k);
    else return select(A, q + 1, right, k - i);
}

int medianOfMedians(vector<int>& A, int left, int right) {
    if (right - left + 1 <= groupSize) {
        vector<int> temp(A.begin() + left, A.begin() + right + 1);
        sort(temp.begin(), temp.end(), [](int a, int b) {
            comparisons++;
            return a < b;
        });
        return temp[temp.size() / 2];
    }

    vector<int> medians;
    for (int i = left; i <= right; i += groupSize) {
        int subEnd = min(i + groupSize - 1, right);
        vector<int> group(A.begin() + i, A.begin() + subEnd + 1);
        sort(group.begin(), group.end(), [](int a, int b) {
            comparisons++;
            return a < b;
        });
        medians.push_back(group[group.size() / 2]);
    }

    return select(medians, 0, medians.size() - 1, (medians.size() + 1) / 2);
}

int main(int argc, char* argv[]) {
    int n, k;
    cin >> n;
    arraySize = n;

    if (argc < 2) {
        cerr << "Usage: ./select k [--silent]" << endl;
        return 1;
    }

    k = stoi(argv[1]);

    if (argc >= 3 && string(argv[2]) == "--silent") {
        verbose = false;
    }

    if (argc == 4) {
        groupSize = stoi(argv[3]);
    }

    vector<int> A(n);
    for (int i = 0; i < n; i++) cin >> A[i];

    vector<int> original = A;

    int result = select(A, 0, n - 1, k);

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
