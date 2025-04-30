import matplotlib.pyplot as plt
import pandas as pd
import os

ks = [1, 10, 50]

for k in ks:
    df_rand = pd.read_csv(f'results2/k{k}/random_select.csv')
    df_median = pd.read_csv(f'results2/k{k}/select.csv')

    plt.figure(figsize=(10, 5))
    plt.plot(df_rand['n'], df_rand['comparisons'], label='Random Select', marker='o', linewidth=1)
    plt.plot(df_median['n'], df_median['comparisons'], label='Select', marker='s', linewidth=1)
    plt.title(f'Comparison count for k = {k}')
    plt.xlabel('Array size (n)')
    plt.ylabel('Comparison count')
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(f'results2/k{k}/comparisons_k{k}.png')
    plt.close()

    plt.figure(figsize=(10, 5))
    plt.plot(df_rand['n'], df_rand['swaps'], label='Random Select', marker='o', linewidth=1)
    plt.plot(df_median['n'], df_median['swaps'], label='Select', marker='s', linewidth=1)
    plt.title(f'Swaps count for k = {k}')
    plt.xlabel('Array size (n)')
    plt.ylabel('Swaps count')
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(f'results2/k{k}/swaps_k{k}.png')
    plt.close()

print("Plots saved.")
