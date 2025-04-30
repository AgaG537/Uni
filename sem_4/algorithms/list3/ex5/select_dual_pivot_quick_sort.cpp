// dual_pivot_quick_sort.cpp
#include "select.hpp"
#include <iostream>
#include <vector>
#include <iomanip>
using namespace std;

extern int comparisons;
extern int swaps;

bool compare(int a, int b) {
    comparisons++;
    return a < b;
}

void swap_keys(vector<int>& A, int i, int j) {
    if (i != j) {
        swaps++;
        std::swap(A[i], A[j]);
    }
}

void printArray(const vector<int>& A) {
    for (int x : A) cout << setw(2) << x << " ";
    cout << "\n";
}

bool is_sorted(const vector<int>& A) {
    for (int i = 1; i < (int)A.size(); i++)
        if (A[i-1] > A[i]) return false;
    return true;
}

void dualPivotPartition(vector<int>& A, int low, int high, int& lp, int& rp) {
    int len = high - low + 1;
    // 1) Wybór pivotów na kopii, by nie mutować A
    vector<int> tmp(A.begin() + low, A.begin() + high + 1);
    int p = select(tmp, 0, len - 1, (len + 2) / 3);
    int q = select(tmp, 0, len - 1, 2 * (len + 1) / 3);
    if (p > q) std::swap(p, q);

    // 2) Znalezienie i przeniesienie pivotów do A[low], A[high]
    int pIndex = -1, qIndex = -1;
    for (int i = low; i <= high; ++i) {
        if (A[i] == p && pIndex < 0) pIndex = i;
        if (A[i] == q)             qIndex = i;
    }
    if (pIndex < 0 || qIndex < 0) {
        cerr << "Pivot not found!\n";
        exit(1);
    }
    swap_keys(A, low,  pIndex);
    // jeśli pivot1 był na high, to teraz się przeniósł na pIndex
    if (qIndex == low) qIndex = pIndex;
    swap_keys(A, high, qIndex);

    // 3) Odczyt pivotów w nowych pozycjach
    p = A[low];
    q = A[high];

    // 4) Trójpodział z count-based strategią
    int lt = low + 1, i = low + 1, gt = high - 1;
    int small_count = 0, large_count = 0;

    while (i <= gt) {
        if (large_count > small_count) {
            // najpierw duże przestawienia
            if (compare(q, A[i])) {              // A[i] > q?
                swap_keys(A, i, gt--);
                large_count++;
            }
            else if (compare(A[i], p)) {         // A[i] < p?
                swap_keys(A, i, lt++);
                small_count++;
                i++;
            }
            else {
                i++;
            }
        } else {
            // najpierw małe przestawienia
            if (compare(A[i], p)) {             // A[i] < p?
                swap_keys(A, i, lt++);
                small_count++;
                i++;
            }
            else if (compare(q, A[i])) {        // A[i] > q?
                swap_keys(A, i, gt--);
                large_count++;
            }
            else {
                i++;
            }
        }
    }

    // 5) Przeniesienie pivotów do pozycji lt-1 i gt+1
    swap_keys(A, low,  --lt);
    swap_keys(A, high, ++gt);
    lp = lt;
    rp = gt;

    // debug dla małych n
    if (len < 40) {
        cout << "After partition [" << low << "," << high
             << "] — lp=" << lp << ", rp=" << rp << ": ";
        printArray(A);
    }
}

void dualPivotQuickSort(vector<int>& A, int low, int high, int n) {
    if (low < high) {
        int lp, rp;
        dualPivotPartition(A, low, high, lp, rp);
        dualPivotQuickSort(A, low,     lp - 1, n);
        dualPivotQuickSort(A, lp + 1,  rp - 1, n);
        dualPivotQuickSort(A, rp + 1,  high,   n);
    }
    if (n < 40 && low < high) {
        cout << "After sorting [" << low << "," << high << "]: ";
        printArray(A);
    }
}

int main() {
    int n; 
    cin >> n;
    vector<int> A(n), original(n);
    for (int i = 0; i < n; i++) {
        cin >> A[i];
        original[i] = A[i];
    }
    if (n < 40) {
        cout << "Initial array:\n";
        printArray(original);
    }

    dualPivotQuickSort(A, 0, n - 1, n);

    if (n < 40) {
        cout << "Original:\n"; printArray(original);
        cout << "Sorted:  \n"; printArray(A);
    }

    cout << "Comparisons: " << comparisons << "\n"
         << "Swaps:       " << swaps     << "\n"
         << (is_sorted(A)
                 ? "The array is sorted correctly.\n"
                 : "The array is NOT sorted correctly.\n");
    return 0;
}