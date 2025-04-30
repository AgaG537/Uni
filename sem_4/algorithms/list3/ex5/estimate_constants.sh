#!/bin/bash

OUTPUT_FILE="results/estimated_constants.csv"
mkdir -p results

# Function to execute the sorting program and retrieve the number of comparisons
run_sorting_program() {
    local program="$1"
    local n="$2"
    
    local comparisons=$(./gen_random "$n" | ./"$program" | awk '/Comparisons:/ {print $2}')
    
    # Return the number of comparisons or -1 if empty
    echo "${comparisons:- -1}"
}

# Function to run the experiment and calculate the average k(n)
run_experiment() {
    local program="$1"
    local start="$2"
    local step="$3"
    local end="$4"
    local repetitions="$5"
    
    echo "$program:" >> "$OUTPUT_FILE"
    
    local sum_k=0
    local count=0

    for ((n=start; n<=end; n+=step)); do
        local avg_k=0
        local valid_runs=0

        for ((i=0; i<repetitions; i++)); do
            local comparisons
            comparisons=$(run_sorting_program "$program" "$n")

            if [[ "$comparisons" -ne -1 ]]; then
                local expected
                expected=$(echo "scale=10; $n * (l($n) / l(e(1)))" | bc -l)
                local k_value
                k_value=$(echo "scale=10; $comparisons / $expected" | bc -l)

                avg_k=$(echo "$avg_k + $k_value" | bc -l)
                valid_runs=$((valid_runs + 1))
            fi
        done

        if [[ "$valid_runs" -gt 0 ]]; then
            avg_k=$(echo "scale=10; $avg_k / $valid_runs" | bc -l)
            sum_k=$(echo "$sum_k + $avg_k" | bc -l)
            count=$((count + 1))

            echo "$n,$avg_k" >> "$OUTPUT_FILE"
        fi
    done

    # Return the final average k
    if [[ "$count" -gt 0 ]]; then
        echo "scale=10; $sum_k / $count" | bc -l
    else
        echo "-1"
    fi
}

echo "Running experiment for QuickSort..."
avg_k_quick=$(run_experiment "quick_sort" 1000 1000 50000 10)

echo "Running experiment for Dual-Pivot QuickSort..."
avg_k_dual=$(run_experiment "dual_pivot_quick_sort" 1000 1000 50000 10)

{
    echo ""
    echo "Final Experimental Results:"
    echo "Average k for QuickSort: $avg_k_quick"
    echo "Average k for Dual-Pivot QuickSort: $avg_k_dual"
} | tee -a "$OUTPUT_FILE"

echo "Experiment completed. Results saved in $OUTPUT_FILE"