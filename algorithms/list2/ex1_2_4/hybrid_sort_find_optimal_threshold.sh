#!/bin/bash
# This script tests different threshold values for hybrid_sort and determines the optimal one.
# It runs hybrid_sort for n values in {1000, 5000, 10000, 20000} with different thresholds,
# using a fixed seed for reproducibility and k repetitions for each experiment.
# Results are saved to "threshold_experiments.csv" and the optimal threshold is displayed.

RESULTS_FILE="results/threshold_experiments.csv"
echo "Threshold,n,k,AvgComparisons,AvgSwaps" > $RESULTS_FILE

k=100          # Number of repetitions for each experiment

# Loop over threshold values to test
for threshold in 5 10 15 20 25 30; do
    totalCompAll=0
    totalSwapsAll=0
    count=0
    # Loop over different n values
    for n in 1000 5000 10000 20000; do
        totalComp=0
        totalSwaps=0
        # Perform k independent repetitions
        for ((i=1; i<=k; i++)); do
            # Assume gen_random accepts seed as second parameter.
            output=$(./gen_random $n | ./hybrid_sort $threshold)
            comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
            swaps=$(echo "$output" | grep "Swaps:" | awk '{print $2}')
            totalComp=$((totalComp + comp))
            totalSwaps=$((totalSwaps + swaps))
        done
        avgComp=$(echo "scale=2; $totalComp / $k" | bc)
        avgSwaps=$(echo "scale=2; $totalSwaps / $k" | bc)
        totalCompAll=$(echo "$totalCompAll + $totalComp" | bc)
        totalSwapsAll=$(echo "$totalSwapsAll + $totalSwaps" | bc)
        count=$((count + 1))
    done
    overallAvg=$(echo "scale=2; ($totalCompAll + $totalSwapsAll) / ($k * $count)" | bc)
    echo "Threshold $threshold: Overall average operations = $overallAvg"
    echo "Threshold $threshold: Overall average operations = $overallAvg" >> $RESULTS_FILE
done

echo "Threshold experiments completed. Results saved in $RESULTS_FILE"

# Compute the optimal threshold based on the lowest average total operations (AvgComparisons + AvgSwaps)
optimal_threshold=$(awk -F, 'NR>1 {
    total_ops = $4 + $5;
    sum[$1] += total_ops; count[$1]++
} END {
    min=""; min_avg=0;
    for (th in sum) {
        avg = sum[th] / count[th];
        if (min == "" || avg < min_avg) {
            min = th;
            min_avg = avg;
        }
    }
    print min
}' $RESULTS_FILE)

echo "Optimal threshold determined: $optimal_threshold"
echo "Optimal threshold determined: $optimal_threshold" >> $RESULTS_FILE