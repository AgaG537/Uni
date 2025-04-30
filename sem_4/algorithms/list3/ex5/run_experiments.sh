#!/bin/bash

RESULTS_FILE="experiment_results.csv"
echo "Algorithm,n,k,AvgComparisons,AvgSwaps" > $RESULTS_FILE

ks=(1 10 100)

echo "Starting experiments..."
echo "Results will be saved in: $RESULTS_FILE"

for k in "${ks[@]}"; do
    for n in $(seq 1000 1000 50000); do
        echo "Running tests for n=$n, k=$k..."

        for algorithm in "quick_sort" "dual_pivot_quick_sort" "select_qs" "select_dpqs"; do
            echo "  Running $algorithm..."
            totalComp=0
            totalSwaps=0
            for ((i=1; i<=k; i++)); do
                output=$(./gen_random $n | ./$algorithm)
                comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
                swaps=$(echo "$output" | grep "Swaps:" | awk '{print $2}')
                totalComp=$((totalComp + comp))
                totalSwaps=$((totalSwaps + swaps))
            done
            avgComp=$(echo "scale=2; $totalComp / $k" | bc)
            avgSwaps=$(echo "scale=2; $totalSwaps / $k" | bc)
            echo "$algorithm,$n,$k,$avgComp,$avgSwaps" >> $RESULTS_FILE
            echo "  Completed $algorithm (n=$n, k=$k)."
        done
    done
done

echo "Experiments completed. Results saved in $RESULTS_FILE"