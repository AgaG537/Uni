import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

os.makedirs("results/small_n", exist_ok=True)
os.makedirs("results/large_n", exist_ok=True)

df = pd.read_csv("experiment_results.csv")

# Separate datasets
df_small = df[df["n"] <= 50].copy()
df_large = df[df["n"] >= 1000].copy()

def plot_results(df, dataset_type):
    ks = df["k"].unique()
    metrics = ["AvgComparisons"]
    
    print(f"Generating plots for {dataset_type}...")

    for k in ks:
        print(f"  Processing k={k}...")

        df_k = df[df["k"] == k].copy()

        for metric in metrics:
            print(f"    Creating plot: {metric} vs n...")
            plt.figure(figsize=(10, 6))
            sns.lineplot(data=df_k, x="n", y=metric, hue="Algorithm", marker="o")
            plt.xlabel("n")
            plt.ylabel(metric)
            plt.title(f"{metric} vs n ({dataset_type}, k={k})")
            plt.legend()
            plt.savefig(f"results/{dataset_type}/{metric}_k{k}.png")
            plt.close()

        for metric in metrics:
            df_k.loc[:, f"{metric}_per_n"] = df_k[metric] / df_k["n"]
            print(f"    Creating plot: {metric}/n vs n...")
            plt.figure(figsize=(10, 6))
            sns.lineplot(data=df_k, x="n", y=f"{metric}_per_n", hue="Algorithm", marker="o")
            plt.xlabel("n")
            plt.ylabel(f"{metric}/n")
            plt.title(f"{metric}/n vs n ({dataset_type}, k={k})")
            plt.legend()
            plt.savefig(f"results/{dataset_type}/{metric}_per_n_k{k}.png")
            plt.close()

plot_results(df_small, "small_n")
plot_results(df_large, "large_n")

print("Plots have been saved in the 'results/' directory.")

