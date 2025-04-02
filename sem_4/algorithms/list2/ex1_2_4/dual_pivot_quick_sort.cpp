#include <iostream>
#include <vector>
#include <iomanip>
#include <algorithm>
using namespace std;

int comparisons = 0;
int swaps = 0;

bool compare(int a, int b) {
    comparisons++;
    return a < b;
}

void swap_keys(vector<int>& arr, int i, int j) {
    if (i != j) {
        swaps++;
        swap(arr[i], arr[j]);
    }
}

void printArray(const vector<int>& arr) {
    for (int num : arr)
        cout << setw(2) << num << " ";
    cout << endl;
}

bool is_sorted(const vector<int>& arr) {
    for (size_t i = 1; i < arr.size(); i++) {
        if (arr[i - 1] > arr[i])
            return false;
    }
    return true;
}

void dualPivotPartition(vector<int>& arr, int low, int high, int& lp, int& rp, int n) {
    if (low >= high) return;

    if (compare(arr[high], arr[low])) 
        swap_keys(arr, low, high);

    int p = arr[low], q = arr[high];
    int lt = low + 1, gt = high - 1, i = low + 1;
    int small_count = 0, large_count = 0;

    while (i <= gt) {
        if (large_count > small_count) {
            if (compare(q, arr[i])) {
                swap_keys(arr, i, gt);
                gt--;
                large_count++;
                continue;
            } else if (compare(arr[i], p)) {
                swap_keys(arr, i, lt);
                lt++;
                small_count++;
            }
        } else {
            if (compare(arr[i], p)) {
                swap_keys(arr, i, lt);
                lt++;
                small_count++;
            } else if (compare(q, arr[i])) {
                swap_keys(arr, i, gt);
                gt--;
                large_count++;
                continue;
            }
        }
        i++;
    }

    swap_keys(arr, low, --lt);
    swap_keys(arr, high, ++gt);

    lp = lt;
    rp = gt;

    if (n < 40) {
        cout << "After partitioning [" << low << ", " << high << "], pivots at " 
             << lp << " and " << rp << ": ";
        printArray(arr);
    }
}

void dualPivotQuickSort(vector<int>& arr, int low, int high, int n) {
    if (low >= high) return;

    int lp, rp;
    dualPivotPartition(arr, low, high, lp, rp, n);

    if (lp > low)
        dualPivotQuickSort(arr, low, lp - 1, n);
    if (lp + 1 < rp)
        dualPivotQuickSort(arr, lp + 1, rp - 1, n);
    if (rp < high)
        dualPivotQuickSort(arr, rp + 1, high, n);

    if (n < 40) {
        cout << "After sorting [" << low << ", " << high << "]: ";
        printArray(arr);
    }
}

int main() {
    int n;
    cin >> n;
    vector<int> arr(n), original(n);

    for (int i = 0; i < n; i++) {
        cin >> arr[i];
        original[i] = arr[i];
    }

    if (n < 40) {
        cout << "Initial array:" << endl;
        printArray(original);
    }

    dualPivotQuickSort(arr, 0, n - 1, n);

    if (n < 40) {
        cout << "Initial array (for comparison):" << endl;
        printArray(original);
        cout << "Final sorted array:" << endl;
        printArray(arr);
    }

    cout << "Comparisons: " << comparisons << endl;
    cout << "Swaps: " << swaps << endl;

    if (is_sorted(arr)) {
        cout << "The array is sorted correctly." << endl;
    } else {
        cout << "The array is NOT sorted correctly." << endl;
    }

    return 0;
}
