import pandas as pd
import matplotlib.pyplot as plt
import os
import sys

EXPERIMENT_RESULTS_CSV = "experiment_results.csv"
PLOTS_DIR = "plots"

def plot_results_from_csv():
    print(f"\n--- Plotting RB Tree results from {EXPERIMENT_RESULTS_CSV} ---")

    try:
        df = pd.read_csv(EXPERIMENT_RESULTS_CSV)
        print(f"Data loaded successfully from {EXPERIMENT_RESULTS_CSV}.")
    except FileNotFoundError:
        print(f"Error: {EXPERIMENT_RESULTS_CSV} not found.")
        print("Please ensure you have compiled and run the C++ program to generate this file.")
        sys.exit(1)

    os.makedirs(PLOTS_DIR, exist_ok=True)

    metrics = df['metric'].unique()

    scenario_names_map = {
        'ascending_test': 'asc insert, rand delete',
        'random_test': 'rand insert, rand delete'
    }
    metric_names_map = {
        'comparisons': 'Number of Key Comparisons',
        'pointer_operations': 'Number of Pointer Operations',
        'tree_height': 'Tree Height'
    }

    for metric_key in metrics:
        plt.figure(figsize=(10, 6))

        metric_df = df[df['metric'] == metric_key]

        for scenario_key, scenario_display_name in scenario_names_map.items():
            filtered_df = metric_df[metric_df['scenario'] == scenario_key]

            if not filtered_df.empty:
                plt.plot(filtered_df['n'], filtered_df['avg_cost'], marker='o',
                         label=f'{scenario_display_name} (Avg Cost)')
                plt.plot(filtered_df['n'], filtered_df['max_cost'], marker='x', linestyle='--',
                         label=f'{scenario_display_name} (Max Cost)')
            else:
                print(f"No data for: Scenario={scenario_key}, Metric={metric_key}")

        metric_display_name = metric_names_map.get(metric_key, metric_key.replace('_', ' ').title())

        plt.title(f'RB Tree - {metric_display_name}')
        plt.xlabel('Problem Size (n)')
        plt.ylabel(f'{metric_display_name}')
        plt.grid(True)
        plt.legend(loc='upper left')
        plt.tight_layout()
        plot_filename = os.path.join(PLOTS_DIR, f'{metric_key}_all_scenarios.png')
        plt.savefig(plot_filename)
        plt.close()
        print(f"Plot saved: {plot_filename}")

if __name__ == "__main__":
    plot_results_from_csv()
    print("\n--- RB Tree plotting complete. ---")