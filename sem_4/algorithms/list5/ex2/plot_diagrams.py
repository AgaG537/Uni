import pandas as pd
import matplotlib.pyplot as plt

try:
    df = pd.read_csv('results.csv')
except FileNotFoundError:
    print("Error: 'propagation_results.csv' file not found.")
    print("Please ensure the C++ program has been run and generated data to this file.")
    exit()

plt.figure(figsize=(12, 8))
plt.plot(df['n'], df['MinRounds'], marker='^', linestyle=':', label='Minimum rounds')
plt.plot(df['n'], df['AvgRounds'], marker='o', linestyle='-', label='Average rounds')
plt.plot(df['n'], df['MaxRounds'], marker='v', linestyle='--', label='Maximum rounds')
plt.title('Min/Avg/Max rounds needed for information propagation in a tree')
plt.xlabel('Number of vertices (n)')
plt.ylabel('Number of rounds')
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.savefig("plot_min_avg_max_rounds.png")