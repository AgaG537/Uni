import numpy as np
import pandas as pd
from sklearn.metrics import adjusted_rand_score, homogeneity_score, completeness_score, v_measure_score, fowlkes_mallows_score
from sklearn.decomposition import PCA
from sklearn.manifold import TSNE
import tensorflow as tf
import os

from my_dbscan import MyDBSCAN
from visualization import generate_k_distance_plot_tsne, create_tsne_scatter_plot, create_digit_distribution_heatmap


print("--- Loading and preparing MNIST data ---")

mnistDataSet = tf.keras.datasets.mnist
(X_train, y_train), (X_test, y_test) = mnistDataSet.load_data()

# Flatten images (from 28x28 to 784 pixels) and normalize to 0-1 range
X_train_flat = X_train.reshape((-1, X_train.shape[1]*X_train.shape[2])) / 255.0

# Using full training set (60000)
X_sample = X_train_flat
y_sample = y_train

print(f"Shape of original data after flattening and normalization: {X_sample.shape}")
print(f"Shape of labels: {y_sample.shape}")



# Create the plots directory
plots_dir = "plots"
if not os.path.exists(plots_dir):
    os.makedirs(plots_dir)



print("\n--- Performing Dimensionality Reduction (PCA + t-SNE) ---")

print("Applying PCA (n_components=50)...")
pca = PCA(n_components=50, random_state=0)
pca_res_50 = pca.fit_transform(X_sample)
print(f"Shape after PCA: {pca_res_50.shape}")

print("Applying t-SNE (n_components=2)...")
tsne = TSNE(n_components=2, random_state=0, n_jobs=-1, perplexity=30, learning_rate='auto', init='random')
tsne_res = tsne.fit_transform(pca_res_50)
print(f"Shape after t-SNE: {tsne_res.shape}")




# Visualize t-SNE result before clustering
print(f"Generating t-SNE scatter plot with true labels.")
create_tsne_scatter_plot(tsne_res, y_sample, os.path.join(plots_dir, 'tsne_true_labels_plot.png'), title='t-SNE of MNIST Data (True Labels)')
print("t-SNE plot with true labels saved.")

# Generate K-distance Plot for t-SNE data
k_for_distance_plot_tsne = 11
print(f"\n--- Generating K-distance plot for t-SNE data ---")
generate_k_distance_plot_tsne(tsne_res, k_for_distance_plot_tsne, plots_dir)
print("K-distance plot for t-SNE data saved.")



def run_dbscan_and_evaluate(X, y_true, eps, min_samples):
    print(f"\n--- Running DBSCAN with eps={eps}, min_samples={min_samples} ---")
    dbscan = MyDBSCAN(eps=eps, min_samples=min_samples)
    clusters = dbscan.fit_predict(X)

    n_clusters = len(set(clusters)) - (1 if -1 in clusters else 0)
    n_noise = list(clusters).count(-1)
    noise_ratio = n_noise / len(X)

    print(f"  Clusters found: {n_clusters}, Noise points: {n_noise} ({noise_ratio*100:.2f}%)")

    mask = clusters != -1
    if np.sum(mask) == 0:
        print("  Status: All points are noise. No quality metrics can be calculated.")
        return None, 0, n_noise, noise_ratio, float('nan'), float('nan'), float('nan'), float('nan'), float('nan')

    y_true_filtered = y_true[mask]
    clusters_filtered = clusters[mask]

    if len(np.unique(clusters_filtered)) < 2 or len(np.unique(y_true_filtered)) < 2:
        print("  Status: Too few unique clusters or true classes after noise filtering for full quality metrics.")
        homogeneity = completeness = v_measure = adjusted_rand = fowlkes_mallows = float('nan')
    else:
        homogeneity = homogeneity_score(y_true_filtered, clusters_filtered)
        completeness = completeness_score(y_true_filtered, clusters_filtered)
        v_measure = v_measure_score(y_true_filtered, clusters_filtered)
        adjusted_rand = adjusted_rand_score(y_true_filtered, clusters_filtered)
        fowlkes_mallows = fowlkes_mallows_score(y_true_filtered, clusters_filtered)

    print(f"  Homogeneity: {homogeneity:.4f}, Completeness: {completeness:.4f}")
    print(f"  V-measure: {v_measure:.4f}, Adjusted Rand Index (ARI): {adjusted_rand:.4f}")
    print(f"  Fowlkes-Mallows Score: {fowlkes_mallows:.4f}")

    # Visualize t-SNE result with DBSCAN clusters
    cluster_plot_filename = os.path.join(plots_dir, f'tsne_clusters_eps{eps}_min{min_samples}.png')
    create_tsne_scatter_plot(X, clusters, cluster_plot_filename, title=f't-SNE Clusters (eps={eps}, min_samples={min_samples})')
    print(f"  Cluster plot saved as {cluster_plot_filename}")

    return clusters, n_clusters, n_noise, noise_ratio, homogeneity, completeness, v_measure, adjusted_rand, fowlkes_mallows



print("\n--- Starting experimentation with different DBSCAN parameter combinations ---")

eps_values_to_try = [2.0]
min_samples_values_to_try = [11]

print(f"Testing eps values: {eps_values_to_try}")
print(f"Testing min_samples values: {min_samples_values_to_try}")

best_n_clusters = 0
best_noise_ratio = 1.0
best_homogeneity = -1.0
best_completeness = -1.0
best_v_measure = -1.0
best_ari = -1.0
best_fm = -1.0
best_params = {}
best_clusters = None

results = []

total_combinations = len(eps_values_to_try) * len(min_samples_values_to_try)
current_combination_num = 0

for eps in eps_values_to_try:
    for min_samples in min_samples_values_to_try:
        current_combination_num += 1
        print(f"\n--- Processing combination {current_combination_num}/{total_combinations}: eps={eps}, min_samples={min_samples} ---")
        clusters, n_clusters, n_noise, noise_ratio, homo, comp, v_meas, ari, fm = run_dbscan_and_evaluate(
            tsne_res, y_sample, eps, min_samples
        )

        results.append({
            'eps': eps, 'min_samples': min_samples,
            'n_clusters': n_clusters, 'n_noise': n_noise,
            'noise_ratio': noise_ratio,
            'homogeneity': homo, 'completeness': comp, 'v_measure': v_meas,
            'adjusted_rand_index': ari, 'fowlkes_mallows_score': fm,
            'status': 'Clustered' if clusters is not None else 'All noise'
        })

        # Prioritize homogeneity, then low noise, then ARI.
        if not np.isnan(homo): # Ensure clustering occurred and metrics are valid
            if 8 <= n_clusters <= 30:
                if (homo > best_homogeneity or
                    (homo == best_homogeneity and noise_ratio < best_noise_ratio) or
                    (homo == best_homogeneity and noise_ratio == best_noise_ratio and ari > best_ari)):
                    
                    best_homogeneity = homo
                    best_completeness = comp
                    best_v_measure = v_meas
                    best_ari = ari
                    best_fm = fm
                    best_n_clusters = n_clusters
                    best_noise_ratio = noise_ratio
                    best_params = {'eps': eps, 'min_samples': min_samples}
                    best_clusters = clusters
        print(f"  Current best homogeneity: {best_homogeneity:.4f} (at {best_params if best_params else 'N/A'})")

print("\n--- Summary of experimentation results ---")
results_df = pd.DataFrame(results)
print(results_df.to_string())


print("\n--- Best parameters found based on criteria ---")
if best_params:
    print(f"Best parameters: {best_params}")
    print(f"Number of clusters: {best_n_clusters}")
    print(f"Noise percentage: {best_noise_ratio*100:.2f}%")
    print(f"Homogeneity: {best_homogeneity:.4f}")
    print(f"Completeness: {best_completeness:.4f}")
    print(f"V-measure: {best_v_measure:.4f}")
    print(f"Adjusted Rand Index (ARI): {best_ari:.4f}")
    print(f"Fowlkes-Mallows Score: {best_fm:.4f}")

    print("\n--- Generating Digit Distribution Heatmap for Best Parameters ---")
    create_digit_distribution_heatmap(best_clusters, y_sample, plots_dir)

else:
    print("No parameter combination found satisfying the criteria (8 <= clusters <= 30 and valid metrics).")
    print("Try adjusting the ranges of 'eps_values_to_try' and 'min_samples_values_to_try' based on K-distance plot.")



if best_clusters is not None and best_params:
    print("\n--- Evaluating 'Classification Accuracy' and digit distribution in clusters ---")

    cluster_to_digit = {}
    digit_counts = {}

    unique_clusters = np.unique(best_clusters)
    for cluster_id in unique_clusters:
        if cluster_id == -1:
            continue
        digit_counts[cluster_id] = np.zeros(10) # 0-9 digits

    # Populate digit_counts for each cluster
    for i, cluster_id in enumerate(best_clusters):
        if cluster_id != -1:
            digit = y_sample[i]
            digit_counts[cluster_id][digit] += 1

    # Determine the most frequent digit for each cluster
    for cluster_id, counts in digit_counts.items():
        if np.sum(counts) > 0:
            cluster_to_digit[cluster_id] = np.argmax(counts)
        else:
            cluster_to_digit[cluster_id] = -1

    print("\n--- Cluster to Digit Mapping ---")
    if cluster_to_digit:
        for cluster_id, digit_assigned in cluster_to_digit.items():
            if digit_assigned != -1:
                print(f"Cluster {cluster_id} => Assigned Digit: {digit_assigned}")
    else:
        print("No clusters to map (all points are noise or no properly clustered points).")

    correct_predictions = 0
    total_clustered_points = 0

    for i, cluster_id in enumerate(best_clusters):
        if cluster_id != -1 and cluster_id in cluster_to_digit and cluster_to_digit[cluster_id] != -1:
            total_clustered_points += 1
            if y_sample[i] == cluster_to_digit[cluster_id]:
                correct_predictions += 1

    if total_clustered_points > 0:
        accuracy = correct_predictions / total_clustered_points
        print(f"\n'Classification' Accuracy (only for clustered points): {accuracy:.4f}")
        print(f"Number of correctly clustered points: {correct_predictions}")
        print(f"Total number of clustered (non-noise) points: {total_clustered_points}")
        print(f"Total number of points in the dataset: {len(X_sample)}")
    else:
        print("\nCould not calculate accuracy: no clustered points or mapping error.")

    print("\n--- Digit Distribution in Clusters (top 3 most frequent digits) ---")
    if digit_counts:
        for cluster_id, counts in digit_counts.items():
            if cluster_id != -1 and np.sum(counts) > 0:
                total_in_cluster = np.sum(counts)
                sorted_indices = np.argsort(counts)[::-1]
                print(f"Cluster {cluster_id} (assigned to digit {cluster_to_digit[cluster_id]}, Total points: {int(total_in_cluster)}):")
                for i in range(min(3, len(sorted_indices))):
                    digit = sorted_indices[i]
                    count = int(counts[digit])
                    if count > 0:
                        print(f"  Digit {digit}: {count} ({count/total_in_cluster:.2%})")
    else:
        print("No clusters to analyze digit distribution.")
else:
    print("\nNo best clusters to analyze, as optimal parameters were not found.")
    print("Ensure your 'eps' and 'min_samples' ranges are appropriate.")