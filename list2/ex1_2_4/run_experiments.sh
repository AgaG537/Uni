#!/bin/bash
# Runs sorting experiments for different algorithms and values of n and k.
# Saves the results to "experiment_results.csv".

RESULTS_FILE="experiment_results.csv"
echo "Algorithm,Threshold,n,k,AvgComparisons,AvgSwaps" > $RESULTS_FILE

# Define values of k
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

# Run tests for large n (quick_sort, dual_pivot_quick_sort & hybrid_sort)
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



# #!/bin/bash
# # Runs sorting experiments for different algorithms and values of n and k.
# # Saves the results to "experiment_results.csv".

# mkdir -p results

# RESULTS_FILE="results/experiment_results.csv"
# echo "Algorithm,Threshold,n,k,AvgComparisons,AvgSwaps,Type" > $RESULTS_FILE

# # Define values of k
# ks=(1 10 100)
# OPTIMAL_THRESHOLD=15  

# # Define input types
# input_types=("random" "sorted" "reverse")

# # Function to get the correct generator
# generate_input() {
#     case $1 in
#         "random") echo "./gen_random" ;;
#         "sorted") echo "./gen_sorted" ;;
#         "reverse") echo "./gen_reverse" ;;
#     esac
# }

# # Run tests for small n (all algorithms)
# for k in "${ks[@]}"; do
#     for n in $(seq 10 10 50); do
#         for input_type in "${input_types[@]}"; do
#             generator=$(generate_input "$input_type")

#             for algorithm in "insertion_sort" "quick_sort" "dual_pivot_quick_sort"; do
#                 totalComp=0
#                 totalSwaps=0
#                 for ((i=1; i<=k; i++)); do
#                     output=$($generator $n | ./$algorithm)
#                     comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
#                     swaps=$(echo "$output" | grep "Swaps:" | awk '{print $2}')
#                     totalComp=$((totalComp + comp))
#                     totalSwaps=$((totalSwaps + swaps))
#                 done
#                 avgComp=$(echo "scale=2; $totalComp / $k" | bc)
#                 avgSwaps=$(echo "scale=2; $totalSwaps / $k" | bc)
#                 echo "$algorithm,NA,$n,$k,$avgComp,$avgSwaps,$input_type" >> $RESULTS_FILE
#             done

#             # Hybrid Sort with optimized threshold
#             totalComp=0
#             totalSwaps=0
#             for ((i=1; i<=k; i++)); do
#                 output=$($generator $n | ./hybrid_sort $OPTIMAL_THRESHOLD)
#                 comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
#                 swaps=$(echo "$output" | grep "Swaps:" | awk '{print $2}')
#                 totalComp=$((totalComp + comp))
#                 totalSwaps=$((totalSwaps + swaps))
#             done
#             avgComp=$(echo "scale=2; $totalComp / $k" | bc)
#             avgSwaps=$(echo "scale=2; $totalSwaps / $k" | bc)
#             echo "hybrid_sort,$OPTIMAL_THRESHOLD,$n,$k,$avgComp,$avgSwaps,$input_type" >> $RESULTS_FILE
#         done
#     done
# done

# # Run tests for large n (quick_sort, dual_pivot_quick_sort & hybrid_sort)
# for k in "${ks[@]}"; do
#     for n in $(seq 1000 1000 50000); do
#         for input_type in "${input_types[@]}"; do
#             generator=$(generate_input "$input_type")

#             for algorithm in "quick_sort" "dual_pivot_quick_sort" "hybrid_sort"; do
#                 totalComp=0
#                 totalSwaps=0
#                 for ((i=1; i<=k; i++)); do
#                     if [ "$algorithm" == "hybrid_sort" ]; then
#                         output=$($generator $n | ./$algorithm $OPTIMAL_THRESHOLD)
#                     else
#                         output=$($generator $n | ./$algorithm)
#                     fi
#                     comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
#                     swaps=$(echo "$output" | grep "Swaps:" | awk '{print $2}')
#                     totalComp=$((totalComp + comp))
#                     totalSwaps=$((totalSwaps + swaps))
#                 done
#                 avgComp=$(echo "scale=2; $totalComp / $k" | bc)
#                 avgSwaps=$(echo "scale=2; $totalSwaps / $k" | bc)
#                 echo "$algorithm,$OPTIMAL_THRESHOLD,$n,$k,$avgComp,$avgSwaps,$input_type" >> $RESULTS_FILE
#             done
#         done
#     done
# done

# echo "Experiments completed. Results saved in $RESULTS_FILE"





# #!/bin/bash
# # Runs sorting experiments for different algorithms and values of n and k.
# # Saves the results to "experiment_results.csv".

# RESULTS_FILE="experiment_results.csv"
# echo "Algorithm,Threshold,n,k,AvgComparisons,AvgSwaps" > $RESULTS_FILE

# # Define values of k
# ks=(1 10 100)

# # Run tests for small n (all algorithms)
# for k in "${ks[@]}"; do
#     for n in $(seq 10 10 50); do
#         for algorithm in "insertion_sort" "quick_sort" "dual_pivot_quick_sort"; do
#             totalComp=0
#             totalSwaps=0
#             for ((i=1; i<=k; i++)); do
#                 output=$(./gen_random $n | ./$algorithm)
#                 comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
#                 swaps=$(echo "$output" | grep "Swaps:" | awk '{print $2}')
#                 totalComp=$((totalComp + comp))
#                 totalSwaps=$((totalSwaps + swaps))
#             done
#             avgComp=$(echo "scale=2; $totalComp / $k" | bc)
#             avgSwaps=$(echo "scale=2; $totalSwaps / $k" | bc)
#             echo "$algorithm,NA,$n,$k,$avgComp,$avgSwaps" >> $RESULTS_FILE
#         done

#         # Hybrid Sort with optimized threshold
#         OPTIMAL_THRESHOLD=15  # Update with best threshold
#         totalComp=0
#         totalSwaps=0
#         for ((i=1; i<=k; i++)); do
#             output=$(./gen_random $n | ./hybrid_sort $OPTIMAL_THRESHOLD)
#             comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
#             swaps=$(echo "$output" | grep "Swaps:" | awk '{print $2}')
#             totalComp=$((totalComp + comp))
#             totalSwaps=$((totalSwaps + swaps))
#         done
#         avgComp=$(echo "scale=2; $totalComp / $k" | bc)
#         avgSwaps=$(echo "scale=2; $totalSwaps / $k" | bc)
#         echo "hybrid_sort,$OPTIMAL_THRESHOLD,$n,$k,$avgComp,$avgSwaps" >> $RESULTS_FILE
#     done
# done

# # Run tests for large n (quick_sort & hybrid_sort)
# for k in "${ks[@]}"; do
#     for n in $(seq 1000 1000 50000); do
#         for algorithm in "quick_sort" "dual_pivot_quick_sort"; do
#             totalComp=0
#             totalSwaps=0
#             for ((i=1; i<=k; i++)); do
#                 output=$(./gen_random $n | ./$algorithm $OPTIMAL_THRESHOLD)
#                 comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
#                 swaps=$(echo "$output" | grep "Swaps:" | awk '{print $2}')
#                 totalComp=$((totalComp + comp))
#                 totalSwaps=$((totalSwaps + swaps))
#             done
#             avgComp=$(echo "scale=2; $totalComp / $k" | bc)
#             avgSwaps=$(echo "scale=2; $totalSwaps / $k" | bc)
#             echo "$algorithm,$OPTIMAL_THRESHOLD,$n,$k,$avgComp,$avgSwaps" >> $RESULTS_FILE

#             # Hybrid Sort with optimized threshold
#             OPTIMAL_THRESHOLD=15  # Update with best threshold
#             totalComp=0
#             totalSwaps=0
#             for ((i=1; i<=k; i++)); do
#                 output=$(./gen_random $n | ./hybrid_sort $OPTIMAL_THRESHOLD)
#                 comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
#                 swaps=$(echo "$output" | grep "Swaps:" | awk '{print $2}')
#                 totalComp=$((totalComp + comp))
#                 totalSwaps=$((totalSwaps + swaps))
#             done
#             avgComp=$(echo "scale=2; $totalComp / $k" | bc)
#             avgSwaps=$(echo "scale=2; $totalSwaps / $k" | bc)
#             echo "hybrid_sort,$OPTIMAL_THRESHOLD,$n,$k,$avgComp,$avgSwaps" >> $RESULTS_FILE
#         done
#     done
# done

# echo "Experiments completed. Results saved in $RESULTS_FILE" 

#!/bin/bash
# Runs sorting experiments for different algorithms and values of n and k.
# Saves the results to "experiment_results.csv".

# mkdir -p results

# RESULTS_FILE="results/experiment_results.csv"
# echo "Algorithm,Threshold,n,k,AvgComparisons,AvgSwaps" > $RESULTS_FILE

# # Define values of k
# ks=(1 10 100)

# # Define the optimal threshold for hybrid_sort
# OPTIMAL_THRESHOLD=15  

# # Run tests for small n (all algorithms)
# for k in "${ks[@]}"; do
#     for n in $(seq 10 10 50); do
#         for algorithm in "insertion_sort" "quick_sort" "dual_pivot_quick_sort"; do
#             totalComp=0
#             totalSwaps=0
#             for ((i=1; i<=k; i++)); do
#                 output=$(./gen_random $n | ./$algorithm)
#                 comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
#                 swaps=$(echo "$output" | grep "Swaps:" | awk '{print $2}')
#                 totalComp=$((totalComp + comp))
#                 totalSwaps=$((totalSwaps + swaps))
#             done
#             avgComp=$(echo "scale=2; $totalComp / $k" | bc)
#             avgSwaps=$(echo "scale=2; $totalSwaps / $k" | bc)
#             echo "$algorithm,NA,$n,$k,$avgComp,$avgSwaps" >> $RESULTS_FILE
#         done

#         # Hybrid Sort with optimized threshold
#         totalComp=0
#         totalSwaps=0
#         for ((i=1; i<=k; i++)); do
#             output=$(./gen_random $n | ./hybrid_sort $OPTIMAL_THRESHOLD)
#             comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
#             swaps=$(echo "$output" | grep "Swaps:" | awk '{print $2}')
#             totalComp=$((totalComp + comp))
#             totalSwaps=$((totalSwaps + swaps))
#         done
#         avgComp=$(echo "scale=2; $totalComp / $k" | bc)
#         avgSwaps=$(echo "scale=2; $totalSwaps / $k" | bc)
#         echo "hybrid_sort,$OPTIMAL_THRESHOLD,$n,$k,$avgComp,$avgSwaps" >> $RESULTS_FILE
#     done
# done

# # Run tests for large n (quick_sort, dual_pivot_quick_sort & hybrid_sort)
# for k in "${ks[@]}"; do
#     for n in $(seq 1000 1000 50000); do
#         for algorithm in "quick_sort" "dual_pivot_quick_sort" "hybrid_sort"; do
#             totalComp=0
#             totalSwaps=0
#             for ((i=1; i<=k; i++)); do
#                 if [ "$algorithm" == "hybrid_sort" ]; then
#                     output=$(./gen_random $n | ./$algorithm $OPTIMAL_THRESHOLD)
#                 else
#                     output=$(./gen_random $n | ./$algorithm)
#                 fi
#                 comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
#                 swaps=$(echo "$output" | grep "Swaps:" | awk '{print $2}')
#                 totalComp=$((totalComp + comp))
#                 totalSwaps=$((totalSwaps + swaps))
#             done
#             avgComp=$(echo "scale=2; $totalComp / $k" | bc)
#             avgSwaps=$(echo "scale=2; $totalSwaps / $k" | bc)
#             echo "$algorithm,$OPTIMAL_THRESHOLD,$n,$k,$avgComp,$avgSwaps" >> $RESULTS_FILE
#         done
#     done
# done

# echo "Experiments completed. Results saved in $RESULTS_FILE"




# #!/bin/bash
# # run_experiments.sh
# # This script performs k independent repetitions of sorting experiments
# # for various data sizes n and for three types of input (generated by
# # gen_random, gen_sorted, gen_reverse).
# #
# # For small tests (n in {10,20,...,50}), all four algorithms are tested:
# #    insertion_sort, quick_sort, dual_pivot_quick_sort, hybrid_sort.
# # For large tests (n in {1000,2000,...,50000}), only quick_sort,
# # dual_pivot_quick_sort, and hybrid_sort are tested (insertion_sort is excluded).
# #
# # The optimal threshold for hybrid_sort is assumed to be 15.
# #
# # Results are saved in the following directory structure:
# #   results/
# #     ├── small/
# #     │     ├── random/
# #     │     ├── sorted/
# #     │     └── reverse/
# #     └── large/
# #           ├── random/
# #           ├── sorted/
# #           └── reverse/

# # Create results directories
# for size in small large; do
#     for dtype in random sorted reverse; do
#         mkdir -p results/${size}/${dtype}
#     done
# done

# # Define k values (number of repetitions)
# ks=(1 10 100)

# # Define data generators (assumed to be in current directory)
# declare -A generators
# generators=( ["random"]="gen_random" ["sorted"]="gen_sorted" ["reverse"]="gen_reverse" )

# # Define sorting algorithms:
# # For small tests (all four)
# small_algorithms=("insertion_sort" "quick_sort" "dual_pivot_quick_sort" "hybrid_sort")
# # For large tests (exclude insertion_sort)
# large_algorithms=("quick_sort" "dual_pivot_quick_sort" "hybrid_sort")

# # Optimal threshold for hybrid_sort
# OPTIMAL_THRESHOLD=15

# # ---------------------------
# # Function: run_tests
# # Arguments:
# #   $1 - test size ("small" or "large")
# #   $2 - array of n values (passed by name)
# #   $3 - array of algorithm names (passed by name)
# run_tests() {
#     local test_size=$1
#     shift
#     local -n n_values=$1
#     shift
#     local -n algorithms=$1
#     shift

#     for k in "${ks[@]}"; do
#         for n in "${n_values[@]}"; do
#             for dtype in "${!generators[@]}"; do
#                 local generator=${generators[$dtype]}
#                 for algorithm in "${algorithms[@]}"; do
#                     totalComp=0
#                     totalSwaps=0
#                     for ((i=1; i<=k; i++)); do
#                         if [ "$algorithm" == "hybrid_sort" ]; then
#                             # Call hybrid_sort with threshold
#                             output=$(./"$generator" $n | ./"$algorithm" $OPTIMAL_THRESHOLD)
#                         else
#                             output=$(./"$generator" $n | ./"$algorithm")
#                         fi
#                         # Extract the values from the output (assumed to contain lines with "Comparisons:" and "Swaps:")
#                         comp=$(echo "$output" | grep "Comparisons:" | awk '{print $2}')
#                         swaps_val=$(echo "$output" | grep "Swaps:" | awk '{print $2}')
#                         totalComp=$((totalComp + comp))
#                         totalSwaps=$((totalSwaps + swaps_val))
#                     done
#                     avgComp=$(echo "scale=2; $totalComp / $k" | bc)
#                     avgSwaps=$(echo "scale=2; $totalSwaps / $k" | bc)
#                     # Save result into a file:
#                     # results/<test_size>/<dtype>/<algorithm>_n<n>_k<k>.txt
#                     result_file="results/${test_size}/${dtype}/${algorithm}_n${n}_k${k}.txt"
#                     {
#                         echo "Algorithm: $algorithm"
#                         if [ "$algorithm" == "hybrid_sort" ]; then
#                             echo "Threshold: $OPTIMAL_THRESHOLD"
#                         else
#                             echo "Threshold: NA"
#                         fi
#                         echo "n: $n"
#                         echo "k: $k"
#                         echo "AvgComparisons: $avgComp"
#                         echo "AvgSwaps: $avgSwaps"
#                     } > "$result_file"
#                 done
#             done
#         done
#     done
# }

# # Define n ranges for small and large tests
# small_n=($(seq 10 10 50))
# large_n=($(seq 1000 1000 50000))

# # Run tests for small data: all four algorithms
# run_tests "small" small_n small_algorithms

# # Run tests for large data: only quick_sort, dual_pivot_quick_sort, hybrid_sort
# run_tests "large" large_n large_algorithms

# echo "Experiments completed. Results saved in the 'results' directory."
