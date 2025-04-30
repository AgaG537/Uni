#include "select.hpp"
#include <iostream>
#include <vector>
#include <iomanip>
#include <algorithm>
using namespace std;

bool compare(int a, int b) {
    comparisons++;
    return a < b;
}

void swap_keys(vector<int>& arr, int i, int j) {
    swaps++;
    swap(arr[i], arr[j]);
}

void printArray(const vector<int>& arr) {
    for (int num : arr)
        cout << setw(2) << num << " ";
    cout << endl;
}

bool is_sorted(const vector<int>& arr) {
    for (size_t i = 1; i < arr.size(); i++)
        if (arr[i - 1] > arr[i])
            return false;
    return true;
}

int partition(vector<int>& arr, int low, int high) {
    vector<int> temp(arr.begin() + low, arr.begin() + high + 1);
    int pivot = select(temp, 0, temp.size() - 1, (temp.size() + 1) / 2);

    int pivotIndex = -1;
    for (int i = low; i <= high; i++) {
        if (arr[i] == pivot) {
            pivotIndex = i;
            break;
        }
    }

    if (pivotIndex == -1) {
        cerr << "Pivot not found in partition" << endl;
        exit(1);
    }

    swap_keys(arr, pivotIndex, high);
    int i = low - 1;
    for (int j = low; j < high; j++) {
        if (compare(arr[j], pivot)) {
            i++;
            swap_keys(arr, i, j);
        }
    }
    swap_keys(arr, i + 1, high);
    return i + 1;
}

void quickSort(vector<int>& arr, int low, int high) {
    if (low < high) {
        int p = partition(arr, low, high);
        if (arr.size() < 40) {
            cout << "After partition with pivot " << arr[p] 
                 << " in subarray [" << low << ", " << high << "]:" << endl;
            printArray(arr);
        }
        quickSort(arr, low, p - 1);
        quickSort(arr, p + 1, high);
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

    quickSort(arr, 0, n - 1);

    if (n < 40) {
        cout << "Initial array:" << endl;
        printArray(original);
        
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
