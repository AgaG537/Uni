#include "select.hpp"
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

int doCompare(int a, int b) {
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
        if (doCompare(A[j], pivot) <= 0) {
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