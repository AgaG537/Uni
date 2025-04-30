import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.stats import linregress

# Load experiment_results.csv
df = pd.read_csv("experiment_results.csv")

# Make sure the output directory exists
os.makedirs("results", exist_ok=True)

# For each algorithm, fit AvgComparisons ~ a * n·log(n)
for alg in df["Algorithm"].unique():
    df_alg = df[df["Algorithm"] == alg].copy()
    x = df_alg["n"] * np.log(df_alg["n"])
    y = df_alg["AvgComparisons"]
    slope, intercept, r_value, p_value, stderr = linregress(x, y)

    # Round the slope to 4 decimal places
    a_rounded = round(slope, 4)
    print(f"{alg}: a ≈ {a_rounded}")

    # Plot
    plt.figure()
    plt.scatter(x, y, label="Data")
    plt.plot(x, slope * x + intercept, label=f"Fit: y = {a_rounded}·x")
    plt.xlabel("n·log(n)")
    plt.ylabel("Average comparisons")
    plt.title(f"{alg}: AvgComparisons vs n·log(n)")
    plt.legend()
    plt.tight_layout()
    plt.savefig(f"results/{alg}_comp_fit.png")
    plt.close()



os.makedirs("results/worst_case_qs", exist_ok=True)

print("Estimating for worst case qs data:")

df = pd.read_csv("experiment_results_worst_case.csv")

for alg in df["Algorithm"].unique():
    df_alg = df[df["Algorithm"] == alg].copy()
    x = df_alg["n"] * np.log(df_alg["n"])
    y = df_alg["AvgComparisons"]
    slope, intercept, r_value, p_value, stderr = linregress(x, y)

    # Round the slope to 4 decimal places
    a_rounded = round(slope, 4)
    print(f"{alg}: a ≈ {a_rounded}")

    # Plot
    plt.figure()
    plt.scatter(x, y, label="Data")
    plt.plot(x, slope * x + intercept, label=f"Fit: y = {a_rounded}·x")
    plt.xlabel("n·log(n)")
    plt.ylabel("Average comparisons")
    plt.title(f"{alg}: AvgComparisons vs n·log(n)")
    plt.legend()
    plt.tight_layout()
    plt.savefig(f"results/{alg}_worst_case_comp_fit.png")
    plt.close()