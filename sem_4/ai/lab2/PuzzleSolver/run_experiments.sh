#!/bin/bash

mkdir -p "data"

OUTPUT_3X3_H1="data/puzzle_data_3x3_manhattan.txt"
OUTPUT_3X3_H2="data/puzzle_data_3x3_linearConflict.txt"
OUTPUT_4X4_H1="data/puzzle_data_4x4_manhattan.txt"
OUTPUT_4X4_H2="data/puzzle_data_4x4_linearConflict.txt"

NUM_PUZZLES_3=1000
NUM_PUZZLES_4=100

echo "Collecting data for 3x3 puzzles with Manhattan heuristic..."
echo "path_length generated_states visited_states solve_time_ms heuristic_type" > "$OUTPUT_3X3_H1"
for i in $(seq 1 $NUM_PUZZLES_3); do
    ./puzzle_solver 3 manhattan --quiet >> "$OUTPUT_3X3_H1"
done

echo "Collecting data for 3x3 puzzles with Manhattan + Linear Conflict heuristic..."
echo "path_length generated_states visited_states solve_time_ms heuristic_type" > "$OUTPUT_3X3_H2"
for i in $(seq 1 $NUM_PUZZLES_3); do
    ./puzzle_solver 3 linearConflict --quiet >> "$OUTPUT_3X3_H2"
done

echo "Collecting data for 4x4 puzzles with Manhattan heuristic..."
echo "path_length generated_states visited_states solve_time_ms heuristic_type" > "$OUTPUT_4X4_H1"
for i in $(seq 1 $NUM_PUZZLES_4); do
    ./puzzle_solver 4 manhattan --quiet >> "$OUTPUT_4X4_H1"
done

echo "Collecting data for 4x4 puzzles with Manhattan + Linear Conflict heuristic..."
echo "path_length generated_states visited_states solve_time_ms heuristic_type" > "$OUTPUT_4X4_H2"
for i in $(seq 1 $NUM_PUZZLES_4); do
    ./puzzle_solver 4 linearConflict --quiet >> "$OUTPUT_4X4_H2"
done

echo "Data collection complete. Files created: $OUTPUT_3X3_H1, $OUTPUT_3X3_H2, $OUTPUT_4X4_H1, $OUTPUT_4X4_H2"
