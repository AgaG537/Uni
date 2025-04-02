#!/bin/bash

RESULTS_FILE="experiment_results.csv"
echo "Algorithm,Threshold,n,k,AvgComparisons,AvgSwaps" > $RESULTS_FILE

ks=(1 10 100)
OPTIMAL_THRESHOLD=15  

echo "Starting experiments..."
echo "Results will be saved in: $RESULTS_FILE"

# Run tests for small n (all algorithms)
for k in "${ks[@]}"; do
    for n in $(seq 10 10 50); do
        echo "Running tests for n=$n, k=$k..."
        
        for algorithm in "insertion_sort" "quick_sort" "dual_pivot_quick_sort"; do
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
            echo "$algorithm,NA,$n,$k,$avgComp,$avgSwaps" >> $RESULTS_FILE
            echo "  Completed $algorithm (n=$n, k=$k)."
        done

        # Hybrid Sort with optimized threshold
        echo "  Running hybrid_sort..."
        totalComp=0
        totalSwaps=0
        for ((i=1; i<=k; i++)); do
            output=$(./gen_random $n | ./hybrid_sort $OPTIMAL_THRESHOLD)
            comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
            swaps=$(echo "$output" | grep "Swaps:" | awk '{print $2}')
            totalComp=$((totalComp + comp))
            totalSwaps=$((totalSwaps + swaps))
        done
        avgComp=$(echo "scale=2; $totalComp / $k" | bc)
        avgSwaps=$(echo "scale=2; $totalSwaps / $k" | bc)
        echo "hybrid_sort,$OPTIMAL_THRESHOLD,$n,$k,$avgComp,$avgSwaps" >> $RESULTS_FILE
        echo "  Completed hybrid_sort (n=$n, k=$k)."
    done
done

# Run tests for large n (without insertion_sort)
for k in "${ks[@]}"; do
    for n in $(seq 1000 1000 50000); do
        echo "Running tests for large n=$n, k=$k..."

        for algorithm in "quick_sort" "dual_pivot_quick_sort" "hybrid_sort"; do
            echo "  Running $algorithm..."
            totalComp=0
            totalSwaps=0
            for ((i=1; i<=k; i++)); do
                if [ "$algorithm" == "hybrid_sort" ]; then
                    output=$(./gen_random $n | ./$algorithm $OPTIMAL_THRESHOLD)
                else
                    output=$(./gen_random $n | ./$algorithm)
                fi
                comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
                swaps=$(echo "$output" | grep "Swaps:" | awk '{print $2}')
                totalComp=$((totalComp + comp))
                totalSwaps=$((totalSwaps + swaps))
            done
            avgComp=$(echo "scale=2; $totalComp / $k" | bc)
            avgSwaps=$(echo "scale=2; $totalSwaps / $k" | bc)
            echo "$algorithm,$OPTIMAL_THRESHOLD,$n,$k,$avgComp,$avgSwaps" >> $RESULTS_FILE
            echo "  Completed $algorithm (n=$n, k=$k)."
        done
    done
done

echo "Experiments completed. Results saved in $RESULTS_FILE"