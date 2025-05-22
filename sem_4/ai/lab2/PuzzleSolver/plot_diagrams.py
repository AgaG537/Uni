import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os

# --- Configuration ---
DATA_FILES = {
    '3x3_Manhattan': 'data/puzzle_data_3x3_manhattan.txt',
    '3x3_LinearConflict': 'data/puzzle_data_3x3_linearConflict.txt',
    '4x4_Manhattan': 'data/puzzle_data_4x4_manhattan.txt',
    '4x4_LinearConflict': 'data/puzzle_data_4x4_linearConflict.txt',
}
HEURISTIC_NAMES = {1: 'Manhattan', 2: 'Manhattan + Linear Conflict'}
PLOTS_DIR = 'plots'

GLOBAL_COLOR_MANHATTAN = plt.cm.tab10(0)
GLOBAL_COLOR_LINEAR_CONFLICT = plt.cm.tab10(1)

os.makedirs(PLOTS_DIR, exist_ok=True)


# --- Load Data ---
dataframes = {}
for name, filename in DATA_FILES.items():
    if os.path.exists(filename):
        df = pd.read_csv(filename, sep=' ', comment='#')
        df = df[(df['path_length'] != -1) & (df['generated_states'] > 0)].copy()
        
        if 'Manhattan' in name:
            df['heuristic_type'] = 1
        elif 'LinearConflict' in name:
            df['heuristic_type'] = 2
        
        if '3x3' in name:
            df['dimension'] = '3x3'
            df['line_style'] = '-'
        elif '4x4' in name:
            df['dimension'] = '4x4'
            df['line_style'] = '--'

        if not df.empty:
            df['visited_to_generated_ratio'] = df['visited_states'] / df['generated_states']
        
        dataframes[name] = df
        print(f"Loaded {len(df)} records from {filename} for {name}.")
    else:
        print(f"Warning: Data file not found: {filename}. Skipping {name}.")


# --- Plotting Functions ---

def plot_side_by_side_visited_analysis(df_manhattan, df_linear, dimension_name):
    fig, axes = plt.subplots(1, 2, figsize=(16, 7)) 
    fig.suptitle(f'Visited States vs. Solution Length for {dimension_name} Puzzles', fontsize=16)

    # --- Plot for Manhattan Heuristic (Left Subplot) ---
    if df_manhattan is not None and not df_manhattan.empty:
        ax = axes[0]
        ax.scatter(df_manhattan['path_length'], df_manhattan['visited_states'], alpha=0.5, s=30, 
                   color=GLOBAL_COLOR_MANHATTAN, label='Individual Puzzles')
        
        # Calculate Min/Avg/Max per path_length for Manhattan
        min_visited_m = df_manhattan.groupby('path_length')['visited_states'].min()
        avg_visited_m = df_manhattan.groupby('path_length')['visited_states'].mean()
        max_visited_m = df_manhattan.groupby('path_length')['visited_states'].max()

        ax.plot(avg_visited_m.index, avg_visited_m.values, label='Average', 
                color='darkblue', marker='o', markersize=5, linestyle='-')
        ax.plot(min_visited_m.index, min_visited_m.values, label='Min', 
                color='green', linestyle='--', marker='^', markersize=4)
        ax.plot(max_visited_m.index, max_visited_m.values, label='Max', 
                color='red', linestyle=':', marker='v', markersize=4)
        
        ax.set_xlabel('Solution Length (Number of Moves)')
        ax.set_ylabel('Number of Visited States (log scale)')
        ax.set_title(f'{HEURISTIC_NAMES[1]}')
        ax.grid(True, linestyle='--', alpha=0.7)
        ax.set_yscale('log') # Logarithmic scale
        ax.legend()
    else:
        axes[0].set_title(f'{HEURISTIC_NAMES[1]} (No Data)')
        axes[0].text(0.5, 0.5, 'No data available', horizontalalignment='center', verticalalignment='center', transform=axes[0].transAxes)

    # --- Plot for Linear Conflict Heuristic (Right Subplot) ---
    if df_linear is not None and not df_linear.empty:
        ax = axes[1]
        ax.scatter(df_linear['path_length'], df_linear['visited_states'], alpha=0.5, s=30, 
                   color=GLOBAL_COLOR_LINEAR_CONFLICT, label='Individual Puzzles')

        # Calculate Min/Avg/Max per path_length for Linear Conflict
        min_visited_l = df_linear.groupby('path_length')['visited_states'].min()
        avg_visited_l = df_linear.groupby('path_length')['visited_states'].mean()
        max_visited_l = df_linear.groupby('path_length')['visited_states'].max()

        ax.plot(avg_visited_l.index, avg_visited_l.values, label='Average', 
                color='darkorange', marker='o', markersize=5, linestyle='-')
        ax.plot(min_visited_l.index, min_visited_l.values, label='Min', 
                color='green', linestyle='--', marker='^', markersize=4)
        ax.plot(max_visited_l.index, max_visited_l.values, label='Max', 
                color='red', linestyle=':', marker='v', markersize=4)

        ax.set_xlabel('Solution Length (Number of Moves)')
        ax.set_ylabel('Number of Visited States (log scale)')
        ax.set_title(f'{HEURISTIC_NAMES[2]}')
        ax.grid(True, linestyle='--', alpha=0.7)
        ax.set_yscale('log') # Logarithmic scale
        ax.legend()
    else:
        axes[1].set_title(f'{HEURISTIC_NAMES[2]} (No Data)')
        axes[1].text(0.5, 0.5, 'No data available', horizontalalignment='center', verticalalignment='center', transform=axes[1].transAxes)

    plt.tight_layout(rect=[0, 0.03, 1, 0.95])
    plt.savefig(os.path.join(PLOTS_DIR, f'visited_states_analysis_{dimension_name}_combined.png'))
    plt.close(fig)

    print(f"\n--- Statistics for {dimension_name} - Visited States vs. Solution Length ---")
    if df_manhattan is not None and not df_manhattan.empty:
        print(f"  {HEURISTIC_NAMES[1]} (Manhattan): Avg Sol. Length: {df_manhattan['path_length'].mean():.2f}, Avg Visited States: {df_manhattan['visited_states'].mean():.2f}")
    if df_linear is not None and not df_linear.empty:
        print(f"  {HEURISTIC_NAMES[2]} (Linear Conflict): Avg Sol. Length: {df_linear['path_length'].mean():.2f}, Avg Visited States: {df_linear['visited_states'].mean():.2f}")
    print("-" * 40)


def plot_combined_ratio_distribution(df_manhattan, df_linear, dimension_name):
    fig = plt.figure(figsize=(10, 6))

    data_manhattan = df_manhattan['visited_to_generated_ratio'].values if not df_manhattan.empty else np.array([])
    data_linear = df_linear['visited_to_generated_ratio'].values if not df_linear.empty else np.array([])

    all_ratios = []
    if data_manhattan.size > 0:
        all_ratios.extend(data_manhattan)
    if data_linear.size > 0:
        all_ratios.extend(data_linear)

    if not all_ratios:
        print(f"No data to plot combined ratio distribution for {dimension_name}.")
        plt.close(fig)
        return

    min_ratio = np.min(all_ratios)
    max_ratio = np.max(all_ratios)
    bins = np.linspace(min_ratio, max_ratio + 0.001, 20) if min_ratio == max_ratio else np.linspace(min_ratio, max_ratio, 20) 

    hist_data = []
    hist_labels = []
    hist_colors = []

    if data_manhattan.size > 0:
        hist_data.append(data_manhattan)
        hist_labels.append(HEURISTIC_NAMES[1])
        hist_colors.append(GLOBAL_COLOR_MANHATTAN)
    if data_linear.size > 0:
        hist_data.append(data_linear)
        hist_labels.append(HEURISTIC_NAMES[2])
        hist_colors.append(GLOBAL_COLOR_LINEAR_CONFLICT)

    if not hist_data:
        print(f"No valid data to plot combined ratio distribution for {dimension_name} after filtering.")
        plt.close(fig)
        return

    plt.hist(hist_data, bins=bins, edgecolor='black', alpha=0.7, 
             label=hist_labels, color=hist_colors,
             rwidth=0.75, 
             density=False) 
    
    plt.xlabel('Ratio (Visited States / Generated States)')
    plt.ylabel('Frequency') 
    plt.title(f'Distribution of Visited/Generated States Ratio ({dimension_name})')
    plt.legend()
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.savefig(os.path.join(PLOTS_DIR, f'ratio_distribution_combined_{dimension_name}.png'))
    plt.close(fig)

    print(f"\n--- Statistics for {dimension_name} - Visited/Generated Ratio ---")
    if not df_manhattan.empty:
        print(f"    {HEURISTIC_NAMES[1]} Avg Ratio: {df_manhattan['visited_to_generated_ratio'].mean():.4f}")
    if not df_linear.empty:
        print(f"    {HEURISTIC_NAMES[2]} Avg Ratio: {df_linear['visited_to_generated_ratio'].mean():.4f}")
    print("-" * 40)


def plot_combined_solution_length_distribution(df_manhattan, df_linear, dimension_name):
    fig = plt.figure(figsize=(10, 6))

    counts_manhattan = df_manhattan['path_length'].value_counts().sort_index() if not df_manhattan.empty else pd.Series()
    counts_linear = df_linear['path_length'].value_counts().sort_index() if not df_linear.empty else pd.Series()

    all_path_lengths_indices = sorted(list(set(counts_manhattan.index.tolist() + counts_linear.index.tolist())))
    
    if not all_path_lengths_indices:
        print(f"No data to plot combined solution length distribution for {dimension_name}.")
        plt.close(fig)
        return

    bar_width = 0.495 
    
    x_manhattan = np.array(all_path_lengths_indices) - bar_width / 2
    x_linear = np.array(all_path_lengths_indices) + bar_width / 2

    if not counts_manhattan.empty:
        manhattan_heights = [counts_manhattan.get(length, 0) for length in all_path_lengths_indices]
        plt.bar(x_manhattan, manhattan_heights, width=bar_width, 
                label=HEURISTIC_NAMES[1], color=GLOBAL_COLOR_MANHATTAN, 
                edgecolor='black', alpha=0.7)
    
    if not counts_linear.empty:
        linear_heights = [counts_linear.get(length, 0) for length in all_path_lengths_indices]
        plt.bar(x_linear, linear_heights, width=bar_width, 
                label=HEURISTIC_NAMES[2], color=GLOBAL_COLOR_LINEAR_CONFLICT, 
                edgecolor='black', alpha=0.7)
    
    plt.xlabel('Solution Length (Number of Moves)')
    plt.ylabel('Number of Puzzles')
    plt.title(f'Distribution of Solution Lengths ({dimension_name})')
    plt.legend()
    
    plt.xticks(all_path_lengths_indices)
        
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    plt.savefig(os.path.join(PLOTS_DIR, f'solution_length_distribution_combined_{dimension_name}.png'))
    plt.close(fig)

    print(f"\n--- Statistics for {dimension_name} - Solution Length ---")
    if not df_manhattan.empty:
        print(f"    {HEURISTIC_NAMES[1]} Avg Sol. Length: {df_manhattan['path_length'].mean():.2f}")
    if not df_linear.empty:
        print(f"    {HEURISTIC_NAMES[2]} Avg Sol. Length: {df_linear['path_length'].mean():.2f}")
    print("-" * 40)


def compare_heuristics_avg_visited_combined(all_dataframes):
    fig = plt.figure(figsize=(12, 7))

    data_to_plot_found = False
    for name, df in all_dataframes.items():
        if not df.empty:
            avg_visited = df.groupby('path_length')['visited_states'].mean()
            if not avg_visited.empty:
                label = f"{df['dimension'].iloc[0]} {HEURISTIC_NAMES[df['heuristic_type'].iloc[0]]}"
                
                line_color = GLOBAL_COLOR_MANHATTAN if df['heuristic_type'].iloc[0] == 1 else GLOBAL_COLOR_LINEAR_CONFLICT
                line_style = df['line_style'].iloc[0]
                
                plt.plot(avg_visited.index, avg_visited.values, 
                         label=label, 
                         marker='o', 
                         linestyle=line_style, 
                         color=line_color)
                data_to_plot_found = True

    if data_to_plot_found:
        plt.xlabel('Solution Length (Number of Moves)')
        plt.ylabel('Average Visited States (log scale)')
        plt.title('Comparison of Heuristics: Average Visited States by Puzzle Size')
        plt.legend()
        plt.grid(True, linestyle='--', alpha=0.7)
        plt.yscale('log')
        plt.savefig(os.path.join(PLOTS_DIR, f'comparison_heuristics_avg_visited_all_combined.png'))
    else:
        print("No data available to generate combined 'Average Visited States' plot.")
    plt.close(fig)

    print(f"\n--- Overall Averages for All Puzzles ---")
    for name, df in all_dataframes.items():
        if not df.empty:
            print(f"    {name}: Avg Visited: {df['visited_states'].mean():.2f}, Avg Sol. Length: {df['path_length'].mean():.2f}")
    print("-" * 40)


# --- Main execution block ---

# --- Generate Side-by-Side Visited States Analysis Plots per Dimension ---
print("\n--- Generating Side-by-Side Visited States Analysis Plots per Dimension ---")

# 3x3 Puzzles
df_3x3_manhattan = dataframes.get('3x3_Manhattan')
df_3x3_linear = dataframes.get('3x3_LinearConflict')
if df_3x3_manhattan is not None or df_3x3_linear is not None:
    plot_side_by_side_visited_analysis(df_3x3_manhattan, df_3x3_linear, '3x3')
else:
    print("Skipping 3x3 side-by-side visited analysis due to missing data for both heuristics.")

# 4x4 Puzzles
df_4x4_manhattan = dataframes.get('4x4_Manhattan')
df_4x4_linear = dataframes.get('4x4_LinearConflict')
if df_4x4_manhattan is not None or df_4x4_linear is not None:
    plot_side_by_side_visited_analysis(df_4x4_manhattan, df_4x4_linear, '4x4')
else:
    print("Skipping 4x4 side-by-side visited analysis due to missing data for both heuristics.")


# --- Generate Other Combined Heuristic Comparison Plots per Dimension (Ratio and Solution Length Distribution) ---
print("\n--- Generating Other Combined Heuristic Comparison Plots per Dimension ---")

if df_3x3_manhattan is not None and df_3x3_linear is not None:
    print("\nGenerating 3x3 Comparison Plots:")
    plot_combined_ratio_distribution(df_3x3_manhattan, df_3x3_linear, '3x3')
    plot_combined_solution_length_distribution(df_3x3_manhattan, df_3x3_linear, '3x3')
else:
    print("Skipping 3x3 combined plots due to missing data for one or both heuristics.")

if df_4x4_manhattan is not None and df_4x4_linear is not None:
    print("\nGenerating 4x4 Comparison Plots:")
    plot_combined_ratio_distribution(df_4x4_manhattan, df_4x4_linear, '4x4')
    plot_combined_solution_length_distribution(df_4x4_manhattan, df_4x4_linear, '4x4')
else:
    print("Skipping 4x4 combined plots due to missing data for one or both heuristics.")


# --- Generate Combined Heuristics Average Visited States (All dimensions) ---
print("\n--- Generating Combined Heuristics Average Visited States (All dimensions) ---")
compare_heuristics_avg_visited_combined(dataframes)


# --- Time vs. Path Length (Combined for all) ---
fig = plt.figure(figsize=(12, 7))

data_to_plot = False
for name, df in dataframes.items():
    if not df.empty:
        avg_time_per_path = df.groupby('path_length')['solve_time_ms'].mean()
        if not avg_time_per_path.empty:
            line_color = GLOBAL_COLOR_MANHATTAN if df['heuristic_type'].iloc[0] == 1 else GLOBAL_COLOR_LINEAR_CONFLICT
            line_style = df['line_style'].iloc[0]

            plt.plot(avg_time_per_path.index, avg_time_per_path.values, 
                     label=f'{df["dimension"].iloc[0]} {HEURISTIC_NAMES[df["heuristic_type"].iloc[0]]}', 
                     marker='o', 
                     markersize=4, 
                     linestyle=line_style, 
                     color=line_color)
            data_to_plot = True

if data_to_plot:
    plt.xlabel('Solution Length (Number of Moves)')
    plt.ylabel('Average Solve Time (ms) (log scale)')
    plt.title('Average Solve Time vs. Solution Length Across Dimensions and Heuristics')
    plt.legend()
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.yscale('log')
    plt.savefig(os.path.join(PLOTS_DIR, 'average_solve_time_vs_solution_length_all_combined.png'))
else:
    print("No data available to generate 'Average Solve Time vs. Solution Length' plot.")

plt.close(fig)