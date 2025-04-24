#!/bin/bash

set -e

M=50
KS=(1 10 50)
SIZES=$(seq 100 100 50000)

g++ gen_random.cpp -o gen_random
g++ random_select.cpp -o random_select
g++ select.cpp -o select

mkdir -p results2

for k in "${KS[@]}"; do
    echo "Testing for k = $k"
    mkdir -p results2/k${k}
    OUTPUT_RS="results2/k${k}/random_select.csv"
    OUTPUT_MM="results2/k${k}/select.csv"

    echo "n,comparisons,swaps" > "$OUTPUT_RS"
    echo "n,comparisons,swaps" > "$OUTPUT_MM"

    for n in $SIZES; do
        echo "  n = $n"
        for ((i=0; i<$M; i++)); do
            ./gen_random $n > input.txt

            ./random_select $k --silent < input.txt >> temp_rs.txt

            ./select $k --silent < input.txt >> temp_mm.txt
        done

        rs_avg=$(awk -F, '{c+=$1; s+=$2} END {print int(c/NR) "," int(s/NR)}' temp_rs.txt)
        mm_avg=$(awk -F, '{c+=$1; s+=$2} END {print int(c/NR) "," int(s/NR)}' temp_mm.txt)

        echo "$n,$rs_avg" >> "$OUTPUT_RS"
        echo "$n,$mm_avg" >> "$OUTPUT_MM"

        rm -f temp_rs.txt temp_mm.txt
    done
done

echo "All tests completed."
