import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

os.makedirs("results", exist_ok=True)

df = pd.read_csv("experiment_results.csv")

def plot_results():
    ks = df["k"].unique()
    metrics = ["AvgComparisons", "AvgSwaps"]
    
    print(f"Generating plots...")

    for k in ks:
        print(f"  Processing k={k}...")

        df_k = df[df["k"] == k].copy()

        for metric in metrics:
            print(f"    Creating plot: {metric} vs n...")
            plt.figure(figsize=(10, 6))
            sns.lineplot(data=df_k, x="n", y=metric, hue="Algorithm", marker="o")
            plt.xlabel("n")
            plt.ylabel(metric)
            plt.title(f"{metric} vs n (k={k})")
            plt.legend()
            plt.savefig(f"results/{metric}_k{k}.png")
            plt.close()

        for metric in metrics:
            df_k.loc[:, f"{metric}_per_n"] = df_k[metric] / df_k["n"]
            print(f"    Creating plot: {metric}/n vs n...")
            plt.figure(figsize=(10, 6))
            sns.lineplot(data=df_k, x="n", y=f"{metric}_per_n", hue="Algorithm", marker="o")
            plt.xlabel("n")
            plt.ylabel(f"{metric}/n")
            plt.title(f"{metric}/n vs n (k={k})")
            plt.legend()
            plt.savefig(f"results/{metric}_per_n_k{k}.png")
            plt.close()

plot_results()

print("Plots have been saved in the 'results/' directory.")