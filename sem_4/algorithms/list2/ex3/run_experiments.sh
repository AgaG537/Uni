#!/bin/bash

RESULTS_FILE="experiment_results.csv"
echo "Algorithm,n,k,AvgComparisons" > $RESULTS_FILE

ks=(1 10 100)

echo "Starting experiments..."
echo "Results will be saved in: $RESULTS_FILE"

# Run tests for small n
for k in "${ks[@]}"; do
    for n in $(seq 10 10 50); do
        echo "Running tests for n=$n, k=$k..."
        
        for algorithm in "merge_sort" "adaptive_merge_sort"; do
            echo "  Running $algorithm..."
            totalComp=0
            for ((i=1; i<=k; i++)); do
                output=$(./gen_random $n | ./$algorithm)
                comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
                totalComp=$((totalComp + comp))
            done
            avgComp=$(echo "scale=2; $totalComp / $k" | bc)
            echo "$algorithm,$n,$k,$avgComp" >> $RESULTS_FILE
            echo "  Completed $algorithm (n=$n, k=$k)."
        done
    done
done

# Run tests for large n
for k in "${ks[@]}"; do
    for n in $(seq 1000 1000 50000); do
        echo "Running tests for large n=$n, k=$k..."

        for algorithm in "merge_sort" "adaptive_merge_sort"; do
            echo "  Running $algorithm..."
            totalComp=0
            for ((i=1; i<=k; i++)); do
                output=$(./gen_random $n | ./$algorithm)
                comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
                totalComp=$((totalComp + comp))
            done
            avgComp=$(echo "scale=2; $totalComp / $k" | bc)
            echo "$algorithm,$n,$k,$avgComp" >> $RESULTS_FILE
            echo "  Completed $algorithm (n=$n, k=$k)."
        done
    done
done

echo "Experiments completed. Results saved in $RESULTS_FILE"

