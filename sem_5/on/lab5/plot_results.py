import os
import matplotlib.pyplot as plt

RESULTS_DIR = "results"

def load_errors(subdir):
    errors = []
    target_path = os.path.join(RESULTS_DIR, subdir)
    
    # Verify path exists
    if not os.path.exists(target_path):
        print(f"Warning: Directory {target_path} does not exist.")
        return []

    curr_dir = os.getcwd()
    os.chdir(target_path)

    for filename in os.listdir():
        if filename.endswith("res.txt"):
            try:
                num = int(filename.split("res")[0])
                with open(filename, 'r') as f:
                    line = f.readline()
                    if line:
                        errors.append([num, float(line)])
            except ValueError:
                continue

    os.chdir(curr_dir)
    
    # Sort by matrix size
    errors.sort(key=lambda x: x[0])
    return [x[1] for x in errors]

def load_times(subdir):
    times = []
    filepath = os.path.join(RESULTS_DIR, subdir, "times.txt")
    
    if not os.path.exists(filepath):
        print(f"Warning: File {filepath} does not exist.")
        return []

    with open(filepath, 'r') as f:
        for line in f:
            parts = line.split()
            if len(parts) >= 1:
                times.append(float(parts[0]))
    return times

def create_comparison_plot(x_axis, datasets, labels, title, ylabel, log_scale=False):
    plt.figure(figsize=(10, 6))
    for data, label in zip(datasets, labels):
        min_len = min(len(x_axis), len(data))
        plt.plot(x_axis[:min_len], data[:min_len], marker='o', label=label)
    
    plt.title(title)
    plt.xlabel("Matrix Size (n)")
    plt.ylabel(ylabel)
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.legend()
    
    if log_scale:
        plt.yscale('log')
        plt.xscale('log')


# Main Execution

x_sizes = [16, 10000, 50000, 100000, 500000]

# Load Data
std_err = load_errors("standard_error")
piv_err = load_errors("pivot_error")

std_time = load_times("standard")
piv_time = load_times("pivot")

# Plot 1: Relative Errors
if std_err and piv_err:
    create_comparison_plot(
        x_sizes, 
        [std_err, piv_err], 
        ["Standard", "Partial Pivoting"],
        "Relative Error Comparison",
        "Relative Error",
        log_scale=True
    )
    plt.savefig(os.path.join(RESULTS_DIR, "error_comparison_plot.png"))
    print("Error plot saved.")

# Plot 2: Execution Times (full data)
if std_time and piv_time:
    create_comparison_plot(
        x_sizes, 
        [std_time, piv_time], 
        ["Standard", "Partial Pivoting"],
        "Execution Time Comparison (Full Range)",
        "Time (seconds)",
        log_scale=False 
    )
    plt.savefig(os.path.join(RESULTS_DIR, "time_comparison_plot.png"))
    print("Full time plot saved.")

# Plot 3: Execution Times (partial data)
if len(x_sizes) > 1 and std_time and piv_time:
    x_sizes_linear = x_sizes[:-1]
    std_time_linear = std_time[:-1]
    piv_time_linear = piv_time[:-1]

    create_comparison_plot(
        x_sizes_linear, 
        [std_time_linear, piv_time_linear], 
        ["Standard", "Partial Pivoting"],
        "Execution Time Comparison (Linear Range)", 
        "Time (seconds)",
        log_scale=False
    )
    plt.savefig(os.path.join(RESULTS_DIR, "time_comparison_plot_smaller.png"))
    print("Linear time plot saved.")