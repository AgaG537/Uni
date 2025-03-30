import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Create directories for saving plots
os.makedirs("results/small_n", exist_ok=True)
os.makedirs("results/large_n", exist_ok=True)

# Load experimental results
df = pd.read_csv("experiment_results.csv")

# Separate datasets
df_small = df[df["n"] <= 50].copy()
df_large = df[df["n"] >= 1000].copy()

# Define function to plot results
def plot_results(df, dataset_type):
    ks = df["k"].unique()
    metrics = ["AvgComparisons", "AvgSwaps"]
    
    print(f"Generating plots for {dataset_type}...")

    for k in ks:
        print(f"  Processing k={k}...")

        df_k = df[df["k"] == k].copy()  # Avoid SettingWithCopyWarning

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

        # Plot c/n and s/n
        for metric in metrics:
            df_k.loc[:, f"{metric}_per_n"] = df_k[metric] / df_k["n"]  # Fixed warning
            print(f"    Creating plot: {metric}/n vs n...")
            plt.figure(figsize=(10, 6))
            sns.lineplot(data=df_k, x="n", y=f"{metric}_per_n", hue="Algorithm", marker="o")
            plt.xlabel("n")
            plt.ylabel(f"{metric}/n")
            plt.title(f"{metric}/n vs n ({dataset_type}, k={k})")
            plt.legend()
            plt.savefig(f"results/{dataset_type}/{metric}_per_n_k{k}.png")
            plt.close()

# Generate plots
plot_results(df_small, "small_n")
plot_results(df_large, "large_n")

print("Plots have been saved in the 'results/' directory.")




# import os
# import pandas as pd
# import matplotlib.pyplot as plt
# import seaborn as sns

# # Create directories for saving plots
# os.makedirs("results/small_n", exist_ok=True)
# os.makedirs("results/large_n", exist_ok=True)

# # Load experimental results
# df = pd.read_csv("experiment_results.csv")

# # Separate datasets
# df_small = df[df["n"] <= 50].copy()
# df_large = df[df["n"] >= 1000].copy()

# # Define function to plot results
# def plot_results(df, dataset_type):
#     ks = df["k"].unique()
#     input_types = df["Type"].unique()
#     metrics = ["AvgComparisons", "AvgSwaps"]
    
#     for k in ks:
#         for input_type in input_types:
#             df_k = df[(df["k"] == k) & (df["Type"] == input_type)].copy()  # Copy to avoid warning

#             for metric in metrics:
#                 plt.figure(figsize=(10, 6))
#                 sns.lineplot(data=df_k, x="n", y=metric, hue="Algorithm", marker="o")
#                 plt.xlabel("n")
#                 plt.ylabel(metric)
#                 plt.title(f"{metric} vs n ({dataset_type}, k={k}, {input_type})")
#                 plt.legend()
#                 plt.savefig(f"results/{dataset_type}/{metric}_k{k}_{input_type}.png")
#                 plt.close()

#             # Plot c/n and s/n
#             for metric in metrics:
#                 df_k.loc[:, f"{metric}_per_n"] = df_k[metric] / df_k["n"]  # Fixed warning
#                 plt.figure(figsize=(10, 6))
#                 sns.lineplot(data=df_k, x="n", y=f"{metric}_per_n", hue="Algorithm", marker="o")
#                 plt.xlabel("n")
#                 plt.ylabel(f"{metric}/n")
#                 plt.title(f"{metric}/n vs n ({dataset_type}, k={k}, {input_type})")
#                 plt.legend()
#                 plt.savefig(f"results/{dataset_type}/{metric}_per_n_k{k}_{input_type}.png")
#                 plt.close()

# # Generate plots
# plot_results(df_small, "small_n")
# plot_results(df_large, "large_n")

# print("Plots saved in 'results/' directory.")





# import os
# import pandas as pd
# import matplotlib.pyplot as plt
# import seaborn as sns

# # Create directories for saving plots
# os.makedirs("results/small_n", exist_ok=True)
# os.makedirs("results/large_n", exist_ok=True)

# # Load experimental results
# df = pd.read_csv("experiment_results.csv")

# # Separate datasets
# df_small = df[df["n"] <= 50]
# df_large = df[df["n"] >= 1000]

# # Define function to plot results
# def plot_results(df, dataset_type):
#     ks = df["k"].unique()
#     metrics = ["AvgComparisons", "AvgSwaps"]
    
#     for k in ks:
#         df_k = df[df["k"] == k]

#         for metric in metrics:
#             plt.figure(figsize=(10, 6))
#             sns.lineplot(data=df_k, x="n", y=metric, hue="Algorithm", marker="o")
#             plt.xlabel("n")
#             plt.ylabel(metric)
#             plt.title(f"{metric} vs n ({dataset_type}, k={k})")
#             plt.legend()
#             plt.savefig(f"results/{dataset_type}/{metric}_k{k}.png")
#             plt.close()

#         # Plot c/n and s/n
#         for metric in metrics:
#             df_k[f"{metric}_per_n"] = df_k[metric] / df_k["n"]
#             plt.figure(figsize=(10, 6))
#             sns.lineplot(data=df_k, x="n", y=f"{metric}_per_n", hue="Algorithm", marker="o")
#             plt.xlabel("n")
#             plt.ylabel(f"{metric}/n")
#             plt.title(f"{metric}/n vs n ({dataset_type}, k={k})")
#             plt.legend()
#             plt.savefig(f"results/{dataset_type}/{metric}_per_n_k{k}.png")
#             plt.close()

# # Generate plots
# plot_results(df_small, "small_n")
# plot_results(df_large, "large_n")

# print("Plots saved in 'results/' directory.")




# import os
# import pandas as pd
# import matplotlib.pyplot as plt
# import seaborn as sns

# sns.set(style="whitegrid")

# def read_results(base_dir):
#     """
#     Reads all result files from base_dir (recursively) and returns a DataFrame.
#     Expected file content (each file):
#       Algorithm: <name>
#       Threshold: <value or NA>
#       n: <n>
#       k: <k>
#       AvgComparisons: <value>
#       AvgSwaps: <value>
#     """
#     data = []
#     # Walk through all subdirectories
#     for root, dirs, files in os.walk(base_dir):
#         for file in files:
#             if file.endswith(".txt"):
#                 path = os.path.join(root, file)
#                 with open(path, "r") as f:
#                     lines = [line.strip() for line in f.readlines()]
#                     try:
#                         algo = lines[0].split(": ")[1]
#                         threshold = lines[1].split(": ")[1]
#                         n = int(lines[2].split(": ")[1])
#                         k = int(lines[3].split(": ")[1])
#                         avgComp = float(lines[4].split(": ")[1])
#                         avgSwaps = float(lines[5].split(": ")[1])
#                         # Extract test size and data type from path:
#                         # Expected path: results/<test_size>/<data_type>/...
#                         parts = os.path.normpath(path).split(os.sep)
#                         test_size = parts[1]  # small or large
#                         data_type = parts[2]  # random, sorted, or reverse
#                         data.append([algo, threshold, n, k, avgComp, avgSwaps, test_size, data_type])
#                     except Exception as e:
#                         print(f"Error reading file {path}: {e}")
#     df = pd.DataFrame(data, columns=["Algorithm", "Threshold", "n", "k", "AvgComparisons", "AvgSwaps", "TestSize", "DataType"])
#     return df

# # Read results from the 'results' directory
# df = read_results("results")

# # Function to generate plots for a given dataset (df_subset) and output folder
# def plot_results(df_subset, output_dir):
#     os.makedirs(output_dir, exist_ok=True)
#     ks = df_subset["k"].unique()
#     metrics = ["AvgComparisons", "AvgSwaps"]

#     for k in ks:
#         df_k = df_subset[df_subset["k"] == k].copy()

#         for metric in metrics:
#             plt.figure(figsize=(10, 6))
#             sns.lineplot(data=df_k, x="n", y=metric, hue="Algorithm", style="DataType", marker="o")
#             plt.xlabel("n")
#             plt.ylabel(metric)
#             plt.title(f"{metric} vs n (k={k})")
#             plt.legend()
#             plt.savefig(os.path.join(output_dir, f"{metric}_k{k}.png"))
#             plt.close()

#         # Plot ratios: metric/n
#         for metric in metrics:
#             col_name = f"{metric}_per_n"
#             df_k.loc[:, col_name] = df_k[metric] / df_k["n"]
#             plt.figure(figsize=(10, 6))
#             sns.lineplot(data=df_k, x="n", y=col_name, hue="Algorithm", style="DataType", marker="o")
#             plt.xlabel("n")
#             plt.ylabel(f"{metric} / n")
#             plt.title(f"{metric}/n vs n (k={k})")
#             plt.legend()
#             plt.savefig(os.path.join(output_dir, f"{metric}_per_n_k{k}.png"))
#             plt.close()

# # Generate plots for small and large data separately
# plot_results(df[df["TestSize"] == "small"], os.path.join("plots", "small_n"))
# plot_results(df[df["TestSize"] == "large"], os.path.join("plots", "large_n"))

# print("✅ All plots generated successfully!")
