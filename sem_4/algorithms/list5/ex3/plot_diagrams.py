import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os

os.makedirs("plots", exist_ok=True)

# Plot 1: Comparisons for n=500 trials (showing all trials on one plot per op type)
def plot_detailed_experiments(filename="exp_n500.csv"):
    df = pd.read_csv(filename)

    df = df.sort_values(by=['trial', 'operation_type', 'operation_index'])

    unique_trials = sorted(df['trial'].unique())
    num_trials = len(unique_trials)

    colors_list = plt.cm.tab10.colors 
    trial_color_map = {trial: colors_list[i % len(colors_list)] for i, trial in enumerate(unique_trials)}

    # --- Combined Plots for All Trials per Operation Type ---
    print("Generating combined plots for all 5 trials per operation type...")

    fig_all_trials_combined, axes_all_trials_combined = plt.subplots(3, 1, figsize=(15, 18), sharex=False)
    fig_all_trials_combined.suptitle("Comparisons per operation (n=500) - all 5 trials", fontsize=16)

    # 1. All Trials: Insert Operations
    ax_inserts = axes_all_trials_combined[0]
    for trial_num in unique_trials:
        trial_df = df[df['trial'] == trial_num]
        inserts_data = trial_df[trial_df['operation_type'] == 'insert']

        color_for_trial = trial_color_map[trial_num]

        ax_inserts.plot(inserts_data['operation_index'], inserts_data['comparisons'],
                       label=f'Trial {trial_num} - Insert', linestyle='-',
                       marker='o', markersize=3, alpha=0.7, color=color_for_trial)

    ax_inserts.set_title('Insert operations')
    ax_inserts.set_ylabel('Comparisons')
    ax_inserts.legend(ncol=2, loc='upper right', fontsize='small')
    ax_inserts.grid(True, linestyle=':', alpha=0.6)

    # 2. All Trials: Union Operation
    ax_union = axes_all_trials_combined[1]
    union_data = df[df['operation_type'] == 'union']
    
    union_comparisons = [union_data[union_data['trial'] == t]['comparisons'].iloc[0] for t in unique_trials]
    bar_labels = [f'Trial {t}' for t in unique_trials]
    bar_colors = [trial_color_map[t] for t in unique_trials]
    
    ax_union.bar(bar_labels, union_comparisons, color=bar_colors, width=0.6, alpha=0.9)
    ax_union.set_title('Union operations')
    ax_union.set_ylabel('Comparisons')
    ax_union.grid(True, linestyle=':', alpha=0.6, axis='y')

    # 3. All Trials: Extract-Min Operations
    ax_extract = axes_all_trials_combined[2]
    for trial_num in unique_trials:
        trial_df = df[df['trial'] == trial_num]
        extract_data = trial_df[trial_df['operation_type'] == 'extractMin']

        color_for_trial = trial_color_map[trial_num]

        ax_extract.plot(extract_data['operation_index'], extract_data['comparisons'],
                        label=f'Trial {trial_num} - Extract-Min', linestyle='-',
                        marker='o', markersize=3, alpha=0.7, color=color_for_trial)

    ax_extract.set_title('Extract-Min operations')
    ax_extract.set_xlabel('Operation Index')
    ax_extract.set_ylabel('Comparisons')
    ax_extract.legend(ncol=2, loc='upper right', fontsize='small')
    ax_extract.grid(True, linestyle=':', alpha=0.6)

    plt.tight_layout(rect=[0, 0.03, 1, 0.96])
    plt.savefig("plots/operations_comparison_count_n500.png")
    plt.close(fig_all_trials_combined)
    print("Finished generating combined plots for all 5 trials per operation type.")


# Plot 2: Average Comparisons per Operation vs. n
def plot_average_costs(filename="avg_cost_by_n.csv"):
    df_avg = pd.read_csv(filename)

    if not {'n', 'avg_comparison_per_op'}.issubset(df_avg.columns):
        raise ValueError("Wrong columns in avg_cost_by_n.csv. Expected 'n' and 'avg_comparison_per_op'.")

    n_values = df_avg['n']
    avg_comparisons = df_avg['avg_comparison_per_op']

    # Calculate log(N) curve
    log_curve = np.log(n_values)

    # Scale it to line up better with data (fit the first point)
    if n_values.iloc[0] > 0 and log_curve.iloc[0] > 0:
        scale = avg_comparisons.iloc[0] / log_curve.iloc[0]
    else:
        scale = avg_comparisons.max() / log_curve.max() if log_curve.max() > 0 else 1.0

    log_curve_scaled = log_curve * scale

    plt.figure(figsize=(10, 6))
    plt.plot(n_values, avg_comparisons, linestyle='-', label="Average comparisons per operation")
    plt.plot(n_values, log_curve_scaled, color='orange', linestyle='--', linewidth=1.5, label=f"$O(\log N)$")

    plt.xlabel('n')
    plt.ylabel('Average comparisons')
    plt.title('Average comparisons per operation vs. n')
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.savefig('plots/avg_comparisons_per_op_plot.png')


if __name__ == "__main__":
    plot_detailed_experiments("exp_n500.csv")
    plot_average_costs("avg_cost_by_n.csv")