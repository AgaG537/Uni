import numpy as np

# Initializes k centroids using the k-means++ method.
def initialize_centroids_kmeans_plusplus(X, k, random_state=None):
    if random_state is not None:
        np.random.seed(random_state)

    n_samples, n_features = X.shape
    centroids = np.zeros((k, n_features))

    first_centroid_idx = np.random.choice(n_samples)
    centroids[0] = X[first_centroid_idx]

    # Choose remaining centroids based on distance to existing ones
    for i in range(1, k):
        distances_sq = np.min(np.sum((X[:, np.newaxis, :] - centroids[:i])**2, axis=2), axis=1)
        sum_distances = np.sum(distances_sq)

        if sum_distances == 0:
            probabilities = np.ones(n_samples) / n_samples
        else:
            probabilities = distances_sq / sum_distances

        next_centroid_idx = np.random.choice(n_samples, p=probabilities)
        centroids[i] = X[next_centroid_idx]

    return centroids

# Custom implementation of the Mini-Batch K-Means clustering algorithm.
def custom_mini_batch_kmeans(X, n_clusters, max_iter=300, batch_size=256, tol=1e-4,
                             n_init=3, random_state=None, verbose=False):
    best_inertia = float('inf')
    best_labels = None
    best_centers = None
    n_samples = X.shape[0]

    if random_state is not None:
        np.random.seed(random_state)

    for init_run in range(n_init):
        if verbose:
            print(f"  Mini-Batch K-Means Init Run {init_run + 1}/{n_init}...")

        centroids = initialize_centroids_kmeans_plusplus(
            X, n_clusters, random_state=random_state + init_run if random_state is not None else None
        )
        centroid_counts = np.zeros(n_clusters)
        prev_centroids = centroids.copy()

        for iter_count in range(max_iter):
            batch_indices = np.random.choice(n_samples, size=batch_size, replace=False)
            X_batch = X[batch_indices]

            # Assign points in batch to closest centroid
            distances_sq_batch = np.sum((X_batch[:, np.newaxis, :] - centroids)**2, axis=2)
            batch_labels = np.argmin(distances_sq_batch, axis=1)

            # Update centroids
            for i in range(n_clusters):
                points_in_this_batch_cluster = X_batch[batch_labels == i]
                if len(points_in_this_batch_cluster) > 0:
                    centroid_counts[i] += len(points_in_this_batch_cluster)
                    learning_rate = len(points_in_this_batch_cluster) / centroid_counts[i]
                    centroids[i] = centroids[i] + (np.mean(points_in_this_batch_cluster, axis=0) - centroids[i]) * learning_rate

            # Check for convergence
            if iter_count % 10 == 0:
                centroid_diff = np.sum((centroids - prev_centroids)**2)
                if verbose:
                    print(f"    Iteration {iter_count + 1}/{max_iter}, Centroid Diff: {centroid_diff:.6f}")
                if centroid_diff < tol:
                    if verbose:
                        print(f"    Converged at iteration {iter_count + 1}.")
                    break
                prev_centroids = centroids.copy()
        else:
            if verbose:
                print(f"    Max iterations ({max_iter}) reached without convergence.")

        # Calculate final labels and inertia for all data points
        distances_sq_full = np.sum((X[:, np.newaxis, :] - centroids)**2, axis=2)
        current_labels = np.argmin(distances_sq_full, axis=1)
        current_inertia = np.sum(np.min(distances_sq_full, axis=1))

        if verbose:
            print(f"  Inertia for this run: {current_inertia:.2f}")

        if current_inertia < best_inertia:
            best_inertia = current_inertia
            best_labels = current_labels
            best_centers = centroids

    return {
        'labels': best_labels,
        'cluster_centers': best_centers,
        'inertia': best_inertia
    }