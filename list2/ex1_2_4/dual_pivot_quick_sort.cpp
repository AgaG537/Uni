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
    if (i != j) { // Unikamy zbędnych swapów
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

// Poprawiona funkcja dual pivot partitioning
void dualPivotPartition(vector<int>& arr, int low, int high, int& lp, int& rp) {
    if (low >= high) return;

    if (compare(arr[high], arr[low])) 
        swap_keys(arr, low, high);

    int p = arr[low], q = arr[high];
    int lt = low + 1, gt = high - 1, i = low + 1;

    while (i <= gt) {
        if (compare(arr[i], p)) {  
            swap_keys(arr, i, lt);
            lt++;
        } else if (compare(q, arr[i])) { 
            swap_keys(arr, i, gt);
            gt--;
            i--; // Ponowne sprawdzenie zamienionego elementu
        }
        i++;
    }

    swap_keys(arr, low, --lt);
    swap_keys(arr, high, ++gt);

    lp = lt;
    rp = gt;
}

// Poprawiona rekurencyjna wersja Dual Pivot Quick Sort
void dualPivotQuickSort(vector<int>& arr, int low, int high) {
    if (low >= high) return;

    int lp, rp;
    dualPivotPartition(arr, low, high, lp, rp);

    if (lp > low)  // Sprawdzenie, czy zakres jest poprawny
        dualPivotQuickSort(arr, low, lp - 1);
    if (lp + 1 < rp)  // Zapewnienie poprawnej rekurencji
        dualPivotQuickSort(arr, lp + 1, rp - 1);
    if (rp < high)  
        dualPivotQuickSort(arr, rp + 1, high);
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

    dualPivotQuickSort(arr, 0, n - 1);

    if (n < 40) {
        cout << "Sorted array:" << endl;
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
