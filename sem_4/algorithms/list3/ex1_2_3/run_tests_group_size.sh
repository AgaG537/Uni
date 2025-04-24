#!/bin/bash

mkdir -p results3

GROUP_SIZES=(3 5 7 9)
N_VALUES=$(seq 100 100 50000)
K=500
REPEATS=50

for G in "${GROUP_SIZES[@]}"; do
    echo "Testing for group size = $G"
    OUT="results3/group$G.csv"
    echo "n,comparisons,swaps,time" > "$OUT"

    for N in $N_VALUES; do
        echo "  n = $N"
        total_comp=0
        total_swaps=0
        total_time=0

        for ((i=0; i<$REPEATS; i++)); do
            ./gen_random $N > input.txt
            start=$(date +%s%N)
            output=$(./select $K --silent $G < input.txt)
            end=$(date +%s%N)
            comps=$(echo $output | cut -d',' -f1)
            swaps=$(echo $output | cut -d',' -f2)
            runtime=$((($end - $start)/1000000))  # in ms
            total_comp=$((total_comp + comps))
            total_swaps=$((total_swaps + swaps))
            total_time=$((total_time + runtime))
        done

        avg_comp=$((total_comp / REPEATS))
        avg_swaps=$((total_swaps / REPEATS))
        avg_time=$((total_time / REPEATS))

        echo "$N,$avg_comp,$avg_swaps,$avg_time" >> "$OUT"
    done
done


echo "All tests completed."