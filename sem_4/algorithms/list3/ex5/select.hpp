#ifndef SELECT_HPP
#define SELECT_HPP

#include <vector>
#include <string>

// Globalne zmienne (monitorowanie działania)
extern int comparisons;
extern int swaps;
extern bool verbose;
extern int groupSize;
extern int arraySize;

// Pomocnicze funkcje do zliczania porównań i zamian
int doCompare(int a, int b);
void doSwap(int& a, int& b);
void printArray(const std::vector<int>& A, const std::string& label);

// Główne funkcje algorytmu Median-of-Medians
int partition(std::vector<int>& A, int left, int right, int pivot);
int medianOfMedians(std::vector<int>& A, int left, int right);
int select(std::vector<int>& A, int left, int right, int k);

#endif // SELECT_HPP
