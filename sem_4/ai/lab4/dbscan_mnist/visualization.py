import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import os
import numpy as np
from sklearn.neighbors import NearestNeighbors
from matplotlib.colors import LogNorm

def generate_k_distance_plot_tsne(X_tsne, k, plots_dir):
    """
    Generates and saves the K-distance plot for DBSCAN parameter selection for 2D t-SNE transformed data.

    Args:
        X_tsne (np.array): The 2D data after t-SNE transformation.
        k (int): The k value for the k-distance calculation (corresponds to min_samples for the plot).
        plots_dir (str): The directory where the plot will be saved.
    """
    neigh = NearestNeighbors(n_neighbors=k)
    nbrs = neigh.fit(X_tsne)
    distances, indices = nbrs.kneighbors(X_tsne)

    # Get the k-th nearest neighbor distance for each point and sort them
    distances = np.sort(distances[:, k - 1], axis=0)
    
    plt.figure(figsize=(12, 6))
    plt.plot(distances)
    plt.title(f'K-distance plot (k={k}) for t-SNE data')
    plt.xlabel('Point Index (sorted)')
    plt.ylabel(f'Distance to {k}-th nearest neighbor')
    plt.grid(True)
    filename = os.path.join(plots_dir, 'k_distance_plot_tsne.png')
    plt.savefig(filename)
    plt.close()
    print(f"K-distance plot for t-SNE data saved as {filename}")


def create_tsne_scatter_plot(X_tsne, labels, filename, title='t-SNE Scatter Plot'):
    """
    Creates and saves a 2D scatter plot of t-SNE results.

    Args:
        X_tsne (np.array): The 2D data after t-SNE transformation.
        labels (np.array): The labels (true labels or cluster assignments).
        filename (str): Path to save the plot.
        title (str): Title of the plot.
    """
    plt.figure(figsize=(16,8))
    
    if -1 in labels: # Check for noise points
        num_unique_labels = len(np.unique(labels))
        # Create a palette: add grey for noise (-1) and use hls_palette for others
        palette = sns.hls_palette(num_unique_labels - 1) + [(0.5, 0.5, 0.5)] # Grey for noise
        
        # Map labels to colors in the custom palette
        unique_labels_sorted = sorted(np.unique(labels))
        color_map = {label: palette[i] for i, label in enumerate(unique_labels_sorted)}
        
        sns.scatterplot(x=X_tsne[:,0], y=X_tsne[:,1], hue=labels, palette=color_map, legend='full', s=10, alpha=0.8)
        
        # Customize legend labels: rename -1 to 'Noise'
        handles, current_labels = plt.gca().get_legend_handles_labels()
        updated_labels = ['Noise' if label == '-1' else label for label in current_labels]
        plt.legend(handles=handles, labels=updated_labels, bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)

    else: # No noise points, just regular clusters/true labels
        sns.scatterplot(x=X_tsne[:,0], y=X_tsne[:,1], hue=labels, palette=sns.hls_palette(len(np.unique(labels))), legend='full', s=10, alpha=0.8)

    plt.title(title)
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(filename)
    plt.close()
    

def create_digit_distribution_heatmap(clusters, true_labels, plots_dir, filename="digit_distribution_heatmap.png", title="Digit Distribution per Cluster"):
    """
    Creates and saves a heatmap showing the distribution of true digits within each cluster.

    Args:
        clusters (np.array): Array of cluster assignments from DBSCAN.
        true_labels (np.array): Array of true labels (digits 0-9) for each data point.
        plots_dir (str): Directory to save the plot.
        filename (str): Name of the file to save the heatmap.
        title (str): Title of the heatmap.
    """
    # Filter out noise points (-1)
    mask = clusters != -1
    clusters_filtered = clusters[mask]
    true_labels_filtered = true_labels[mask]

    if len(np.unique(clusters_filtered)) == 0:
        print("Warning: No non-noise clusters found. Cannot generate digit distribution heatmap.")
        return

    # Create a DataFrame to count occurrences
    df = pd.DataFrame({'Cluster': clusters_filtered, 'True_Digit': true_labels_filtered})
    
    # Cross-tabulate to get counts of each digit in each cluster
    # Fill any missing combinations with 0
    digit_cluster_counts = pd.crosstab(df['True_Digit'], df['Cluster']).fillna(0).astype(int)

    # Sort columns (clusters) by cluster ID
    sorted_clusters = sorted(digit_cluster_counts.columns)
    digit_cluster_counts = digit_cluster_counts[sorted_clusters]

    plt.figure(figsize=(12, 8))
    sns.heatmap(
        digit_cluster_counts,
        annot=True,
        fmt="d",
        cmap="Purples",
        linewidths=.5,
        cbar_kws={'label': 'Number of Data Points'},
        norm=LogNorm()
    )
    plt.title(title)
    plt.xlabel('Cluster ID')
    plt.ylabel('True Digit')
    plt.tight_layout()
    plot_path = os.path.join(plots_dir, filename)
    plt.savefig(plot_path)
    plt.close()
    print(f"Digit distribution heatmap saved as {plot_path}")