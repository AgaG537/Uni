import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import os

# Graphically presents the percentage assignment of digits to clusters (10xN_clusters matrix).
def plot_cluster_digit_assignment(cluster_labels, true_labels, n_clusters):
    if not os.path.exists("plots"):
        os.makedirs("plots")

    assignment_matrix = np.zeros((10, n_clusters))
    for i in range(len(true_labels)):
        true_digit = true_labels[i]
        assigned_cluster = cluster_labels[i]
        assignment_matrix[true_digit, assigned_cluster] += 1

    assignment_matrix_percentage = assignment_matrix / assignment_matrix.sum(axis=1)[:, np.newaxis] * 100

    plt.figure(figsize=(n_clusters * 0.8, 8))
    sns.heatmap(assignment_matrix_percentage,
                annot=True,
                fmt=".1f",
                cmap="YlGnBu",
                xticklabels=[f'Cluster {i}' for i in range(n_clusters)],
                yticklabels=[str(i) for i in range(10)])
    plt.title(f'Percentage Assignment of Digits to Clusters ({n_clusters} Clusters)', fontsize=14)
    plt.xlabel('Assigned Cluster', fontsize=12)
    plt.ylabel('True Digit', fontsize=12)
    plt.tight_layout()

    plot_filename = os.path.join('plots', f'assignment_matrix_{n_clusters}_clusters.png')
    plt.savefig(plot_filename, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"Saved plot: {plot_filename}")


# Graphically displays the centroid images.
def plot_centroids(centroids, n_clusters, title_prefix="Cluster Centroids"):
    if not os.path.exists("plots"):
        os.makedirs("plots")

    n_cols = int(np.ceil(np.sqrt(n_clusters)))
    n_rows = int(np.ceil(n_clusters / n_cols))

    fig, axes = plt.subplots(n_rows, n_cols, figsize=(n_cols * 1.8, n_rows * 2))
    axes = axes.flatten()

    for i in range(n_clusters):
        ax = axes[i]
        ax.imshow(centroids[i].reshape(28, 28), cmap='binary')
        ax.set_title(f'C{i}')
        ax.axis('off')

    for i in range(n_clusters, len(axes)):
        fig.delaxes(axes[i])

    plt.suptitle(f'{title_prefix} ({n_clusters} Clusters)', y=1.02, fontsize=16)
    plt.tight_layout(rect=[0, 0, 1, 0.98])

    plot_filename = os.path.join('plots', f'centroids_{n_clusters}_clusters.png')
    plt.savefig(plot_filename, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"Saved plot: {plot_filename}")