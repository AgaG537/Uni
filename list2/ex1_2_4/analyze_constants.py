import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

# Load results
df = pd.read_csv("experiment_results.csv")

# Filter only QuickSort and Dual-Pivot QuickSort
df = df[df["Algorithm"].isin(["quick_sort", "dual_pivot_quick_sort"])].copy()

# Function to model n log2(n)
def model(x, C):
    return C * x * np.log2(x)

# Estimating the constant C for each algorithm
constants = {}

for algo in ["quick_sort", "dual_pivot_quick_sort"]:
    df_algo = df[df["Algorithm"] == algo]
    
    x_data = df_algo["n"].values
    y_data = df_algo["AvgComparisons"].values

    # Fit curve
    popt, _ = curve_fit(model, x_data, y_data)
    constants[algo] = popt[0]

    # Plot actual vs. fitted
    plt.figure(figsize=(8, 5))
    plt.scatter(x_data, y_data, label="Actual Comparisons", color="blue")
    plt.plot(x_data, model(x_data, *popt), label=f"Fitted: {popt[0]:.4f} * n log2(n)", color="red")
    plt.xlabel("n")
    plt.ylabel("Comparisons")
    plt.title(f"{algo}: Comparisons vs. n log2(n)")
    plt.legend()
    plt.savefig(f"results/{algo}_fit.png")
    plt.close()

# Print estimated constants
print("Estimated constants (C) for Comparisons ≈ C * n log2(n):")
for algo, C in constants.items():
    print(f"{algo}: C ≈ {C:.4f}")
