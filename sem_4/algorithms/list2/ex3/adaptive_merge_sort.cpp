#include <iostream>
#include <vector>
#include <iomanip>
#include <limits>

using namespace std;

int comparisons = 0;

bool compare(int a, int b) {
    comparisons++;
    return a < b;
}

bool is_sorted(const vector<int>& arr) {
    for (size_t i = 1; i < arr.size(); i++) {
        if (arr[i - 1] > arr[i])
            return false;
    }
    return true;
}

void printArray(const vector<int>& arr) {
    for (int num : arr)
        cout << setw(2) << num << " ";
    cout << endl;
}

vector<pair<int, int>> find_runs(const vector<int>& arr) {
    vector<pair<int, int>> runs;
    int n = arr.size();
    int start = 0;

    for (int i = 1; i < n; i++) {
        if (!compare(arr[i - 1], arr[i])) {  
            runs.emplace_back(start, i - 1);
            start = i;
        }
    }
    runs.emplace_back(start, n - 1);  

    return runs;
}

void merge(vector<int>& arr, int left, int mid, int right) {
    vector<int> leftArr(arr.begin() + left, arr.begin() + mid + 1);
    vector<int> rightArr(arr.begin() + mid + 1, arr.begin() + right + 1);

    int i = 0, j = 0, k = left;

    while (i < leftArr.size() && j < rightArr.size()) {
        if (compare(leftArr[i], rightArr[j])) {
            arr[k++] = leftArr[i++];
        } else {
            arr[k++] = rightArr[j++];
        }
    }

    while (i < leftArr.size()) {
        arr[k++] = leftArr[i++];
    }

    while (j < rightArr.size()) {
        arr[k++] = rightArr[j++];
    }
}

void adaptiveMergeSort(vector<int>& arr, int n) {
    vector<pair<int, int>> runs = find_runs(arr);
    
    if (n < 40) {
        cout << "Initial runs detected:" << endl;
        for (auto [start, end] : runs) {
            cout << "[" << start << ", " << end << "] -> ";
            for (int i = start; i <= end; i++) {
                cout << arr[i] << " ";
            }
            cout << endl;
        }
    }

    while (runs.size() > 1) {
        vector<pair<int, int>> newRuns;

        for (size_t i = 0; i < runs.size(); i += 2) {
            if (i + 1 < runs.size()) {
                int left = runs[i].first;
                int mid = runs[i].second;
                int right = runs[i + 1].second;
                merge(arr, left, mid, right);
                newRuns.emplace_back(left, right);

                if (n < 40) {
                    cout << "After merging runs: ";
                    printArray(arr);
                }
            } else {
                newRuns.push_back(runs[i]);
            }
        }

        runs = newRuns;
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

    adaptiveMergeSort(arr, n);

    if (n < 40) {
        cout << "Initial array:" << endl;
        printArray(original);

        cout << "Sorted array:" << endl;
        printArray(arr);
    }

    cout << "Comparisons: " << comparisons << endl;

    if (is_sorted(arr)) {
        cout << "The array is sorted correctly." << endl;
    } else {
        cout << "The array is NOT sorted correctly." << endl;
    }

    return 0;
}
