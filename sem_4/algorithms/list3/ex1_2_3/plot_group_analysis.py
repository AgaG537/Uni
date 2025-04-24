import pandas as pd
import matplotlib.pyplot as plt

group_sizes = [3, 5, 7, 9]
metrics = ["comparisons", "swaps", "time"]
titles = {
    "comparisons": "Number of Comparisons",
    "swaps": "Number of Swaps",
    "time": "Execution Time [ms]"
}

for metric in metrics:
    plt.figure(figsize=(10, 6))
    for g in group_sizes:
        df = pd.read_csv(f"results3/group{g}.csv")
        plt.plot(df['n'], df[metric], label=f"group size = {g}")
    plt.title(f"{titles[metric]} vs n")
    plt.xlabel("Array size (n)")
    plt.ylabel(titles[metric])
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(f"results3/{metric}_group_analysis.png")
    plt.close()
