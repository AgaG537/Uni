!/bin/bash

RESULTS_FILE="experiment_results.csv"
echo "Algorithm,n,k,AvgComparisons,AvgSwaps" > $RESULTS_FILE

echo "Starting experiments..."
echo "Results will be saved in: $RESULTS_FILE"

k=1

for n in $(seq 1000 1000 15000); do
    echo "Running tests for n=$n..."

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

echo "Experiments completed. Results saved in $RESULTS_FILE"



echo "Starting worst-case quick_sort tests..."
RESULTS_FILE_WC="experiment_results_worst_case.csv"
echo "Algorithm,n,k,AvgComparisons,AvgSwaps" > $RESULTS_FILE_WC

k=10
for n in $(seq 1000 1000 15000); do
    echo "Running worst-case tests for n=$n, k=$k..."
    totalComp=0
    totalSwaps=0
    for ((i=1; i<=k; i++)); do
        output=$(./gen_sorted $n | ./select_qs)
        comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
        swaps=$(echo "$output" | grep "Swaps:" | awk '{print $2}')
        totalComp=$((totalComp + comp))
        totalSwaps=$((totalSwaps + swaps))
    done
    avgComp=$(echo "scale=2; $totalComp / $k" | bc)
    avgSwaps=$(echo "scale=2; $totalSwaps / $k" | bc)
    echo "quick_sort,$n,$k,$avgComp,$avgSwaps" >> $RESULTS_FILE_WC
    echo "  Completed quick_sort worst-case (n=$n)."
done

echo "Worst-case quick_sort experiments completed. Results saved in $RESULTS_FILE_WC"
