import pandas as pd
import matplotlib.pyplot as plt
import numpy as np # For numerical operations like log
import os

csv_file_name = 'results.csv'

try:
    df = pd.read_csv(csv_file_name)
    print(f"CSV file '{csv_file_name}' loaded successfully.")
except FileNotFoundError:
    print(f"Error: '{csv_file_name}' file not found.")
    print("Please ensure the C++ program has been run and generated data to this file.")
    exit()
except KeyError as e:
    print(f"Error: Missing expected column in CSV file. Column: {e}")
    print("Please check CSV header for exact column names (e.g., 'n', 'AvgTimePrim', etc.).")
    exit()


if not os.path.exists("plots"):
    os.makedirs("plots")


# --- Plot 1: Average Execution Time ---
plt.figure(figsize=(12, 8))
plt.plot(df['n'], df['AvgTimePrim'], marker='o', linestyle='-', label='Prim\'s Algorithm (μs)')
plt.plot(df['n'], df['AvgTimeKruskal'], marker='x', linestyle='--', label='Kruskal\'s Algorithm (μs)')

plt.title('Average execution time of Prim\'s and Kruskal\'s Algorithms vs. number of vertices (n)')
plt.xlabel('Number of vertices (n)')
plt.ylabel('Average time (microseconds)')
plt.grid(True)
plt.legend()
plt.yscale("log")
plt.tight_layout()
plt.savefig("plots/plot_execution_time.png")
plt.close()


# --- Plot 2: Average Operations vs. Theoretical Complexity ---
plt.figure(figsize=(12, 8))

plt.plot(df['n'], df['AvgPrimOperations'], marker='o', linestyle='-', label='avg Prim\'s operations count')

plt.plot(df['n'], df['AvgKruskalOperations'], marker='x', linestyle='--', label='avg Kruskal\'s operations count')

n_values = df['n'].values
prim_theoretical = n_values**2 * df['AvgPrimOperations'].iloc[0] / (df['n'].iloc[0]**2)
plt.plot(n_values, prim_theoretical, linestyle=':', color='blue', label=f'Prim\'s expected count ($O(N^2)$)')

kruskal_theoretical = n_values**2 * np.log2(n_values)
kruskal_theoretical_scaled = kruskal_theoretical * df['AvgKruskalOperations'].iloc[0] / (df['n'].iloc[0]**2 * np.log2(df['n'].iloc[0]))
plt.plot(n_values, kruskal_theoretical_scaled, linestyle=':', color='red', label=f'Kruskal\'s expected count ($O(N^2 \log N)$)')


plt.title('Average operations count vs. expected complexity')
plt.xlabel('Number of vertices (n)')
plt.ylabel('Average operations count')
plt.grid(True)
plt.legend()
plt.yscale("log")
plt.tight_layout()
plt.savefig("plots/plot_operations_complexity.png")
plt.close()

print(f"Plots saved to 'plots/plot_execution_time.png' and 'plots/plot_operations_complexity.png'")