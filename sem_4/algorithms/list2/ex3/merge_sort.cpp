#include <iostream>
#include <vector>

using namespace std;

int comparison_count = 0;

bool compare(int a, int b) {
    comparison_count++;  
    return a <= b;
}

bool is_sorted(const vector<int>& arr) {
    for (size_t i = 1; i < arr.size(); i++) {
        if (arr[i - 1] > arr[i])
            return false;
    }
    return true;
}

void printArray(const vector<int>& arr) {
    for (int num : arr) cout << num << " ";
    cout << endl;
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

void mergeSort(vector<int>& arr, int left, int right, int n) {
    if (left < right) {
        int mid = left + (right - left) / 2;

        mergeSort(arr, left, mid, n);
        mergeSort(arr, mid + 1, right, n);

        merge(arr, left, mid, right);

        if (n < 40) {
            cout << "After merging [" << left << ", " << right << "]: ";
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

    mergeSort(arr, 0, n - 1, n);

    if (n < 40) {
        cout << "Initial array:" << endl;
        printArray(original);

        cout << "Sorted array:" << endl;
        printArray(arr);
    }

    cout << "Comparisons: " << comparison_count << endl;

    if (is_sorted(arr)) {
        cout << "The array is sorted correctly." << endl;
    } else {
        cout << "The array is NOT sorted correctly." << endl;
    }

    return 0;
}
