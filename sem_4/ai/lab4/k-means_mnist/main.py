import numpy as np
import matplotlib.pyplot as plt
import tensorflow as tf
from tensorflow import keras
import warnings
import os

from my_kmeans import custom_mini_batch_kmeans
from visualization import plot_cluster_digit_assignment, plot_centroids

# Suppress all warnings for cleaner output.
warnings.filterwarnings("ignore")

# Performs k-means clustering using custom_mini_batch_kmeans and selects the model with the lowest inertia.
def perform_kmeans_and_evaluate(n_clusters, X_data, y_labels, n_init_runs=3, batch_size=256):
    print(f"\n--- Starting Mini-Batch K-Means for {n_clusters} clusters (n_init={n_init_runs}, batch_size={batch_size}) ---")
    
    kmeans_results = custom_mini_batch_kmeans(X_data, n_clusters=n_clusters,
                                              max_iter=500,
                                              batch_size=batch_size,
                                              tol=1e-4,
                                              n_init=n_init_runs,
                                              random_state=42,
                                              verbose=True)

    print(f"--- Lowest inertia for {n_clusters} clusters: {kmeans_results['inertia']:.2f} ---\n")
    return kmeans_results

# Analyzes and visualizes the results of the clustering.
def analyze_clusters(kmeans_results, X_data, y_labels, n_clusters):
    cluster_labels = kmeans_results['labels']
    cluster_centroids = kmeans_results['cluster_centers']

    print(f"Analyzing results for {n_clusters} clusters...")

    plot_cluster_digit_assignment(cluster_labels, y_labels, n_clusters)
    plot_centroids(cluster_centroids, n_clusters)

    cluster_to_digit_mapping = np.zeros(n_clusters, dtype=int)
    for i in range(n_clusters):
        indices_in_cluster = np.where(cluster_labels == i)[0]
        if len(indices_in_cluster) > 0:
            digits_in_cluster = y_labels[indices_in_cluster]
            counts = np.bincount(digits_in_cluster)
            cluster_to_digit_mapping[i] = np.argmax(counts)
        else:
            cluster_to_digit_mapping[i] = -1

    print(f"\nMapping of clusters to digits (most frequent digit in cluster):")
    for cluster_id, digit_id in enumerate(cluster_to_digit_mapping):
        if digit_id != -1:
            print(f"  Cluster {cluster_id} -> Digit {digit_id}")
        else:
            print(f"  Cluster {cluster_id} -> No dominant digit (empty cluster)")
    print("-" * 50)


if __name__ == "__main__":
    print("Loading MNIST dataset...")
    (X_train, y_train), (X_test, y_test) = keras.datasets.mnist.load_data()

    X = np.concatenate((X_train, X_test), axis=0)
    y = np.concatenate((y_train, y_test), axis=0)

    X = X.reshape(X.shape[0], -1)
    X = X / 255.0
    y = y.astype(int)

    print(f"Loaded {X.shape[0]} images with {X.shape[1]} pixels each.")
    print("-" * 50)

    n_clusters_to_test = [10, 15, 20, 30]

    NUM_EXTERNAL_KMEANS_RUNS = 3
    BATCH_SIZE = 256

    for n_clusters in n_clusters_to_test:
        kmeans_model_results = perform_kmeans_and_evaluate(n_clusters, X, y,
                                                           n_init_runs=NUM_EXTERNAL_KMEANS_RUNS,
                                                           batch_size=BATCH_SIZE)
        analyze_clusters(kmeans_model_results, X, y, n_clusters)

    print("All clusterings and analyses completed.")