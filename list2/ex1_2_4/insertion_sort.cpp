#include <iostream>
#include <vector>
#include <iomanip>
#include <algorithm>
using namespace std;

int comparisons = 0;
int swaps = 0;

// Function to compare two keys (updates global counter)
bool compare(int a, int b) {
    comparisons++;
    return a < b;
}

// Function to swap two keys in the vector (updates global counter)
void swap_keys(vector<int>& arr, int i, int j) {
    swaps++;
    swap(arr[i], arr[j]);
}

// Print array (keys as two-digit numbers)
void printArray(const vector<int>& arr) {
    for (int num : arr)
        cout << setw(2) << num << " ";
    cout << endl;
}

// Check if array is sorted
bool is_sorted(const vector<int>& arr) {
    for (size_t i = 1; i < arr.size(); i++)
        if (arr[i - 1] > arr[i])
            return false;
    return true;
}

// Insertion Sort with printing of intermediate states
void insertionSort(vector<int>& arr) {
    int n = arr.size();
    // For each iteration, after processing, print intermediate state (if n < 40)
    for (int i = 1; i < n; i++) {
        int j = i;
        while (j > 0 && compare(arr[j], arr[j - 1])) {
            swap_keys(arr, j, j - 1);
            j--;
        }
        if (n < 40) {
            cout << "After iteration " << i << ": ";
            printArray(arr);
        }
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

    insertionSort(arr);

    if (n < 40) {
        cout << "Input array (for comparison):" << endl;
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
