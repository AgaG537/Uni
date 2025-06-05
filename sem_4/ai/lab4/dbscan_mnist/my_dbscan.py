import numpy as np

class MyDBSCAN:
    def __init__(self, eps, min_samples):
        """
        Initializes the DBSCAN algorithm.

        Args:
            eps (float): The maximum distance between two samples for one to be considered
                         as in the neighborhood of the other.
            min_samples (int): The number of samples (or total weight) in a neighborhood for a point
                                to be considered as a core point.
        """
        self.eps = eps
        self.min_samples = min_samples
        self.labels = None          # Array to store cluster labels (-1 for noise)
        self.visited = set()        # Set of indices of visited points

    def _get_neighbors(self, X, p_idx):
        """
        Finds the indices of all points within the 'eps' radius of a given point 'p_idx'.

        Args:
            X (np.array): The data array.
            p_idx (int): The index of the point for which to find neighbors.

        Returns:
            np.array: An array of indices of neighboring points.
        """
        # Using Euclidean norm to calculate distances
        distances = np.linalg.norm(X - X[p_idx], axis=1)
        neighbors = np.where(distances <= self.eps)[0]
        return neighbors

    def _expand_cluster(self, X, p_idx, neighbors, cluster_id):
        """
        Expands a cluster by adding core points and their border points.

        Args:
            X (np.array): The data array.
            p_idx (int): The index of the current core point.
            neighbors (list): A list of indices of neighbors of p_idx.
            cluster_id (int): The ID of the cluster being expanded.
        """
        self.labels[p_idx] = cluster_id
        
        i = 0
        while i < len(neighbors):
            current_p_idx = neighbors[i]

            if current_p_idx not in self.visited:
                self.visited.add(current_p_idx)
                
                current_p_neighbors = self._get_neighbors(X, current_p_idx)

                # If the current point is a core point, add its neighbors to the cluster expansion list
                if len(current_p_neighbors) >= self.min_samples:
                    for n_idx in current_p_neighbors:
                        # Only add if the neighbor is currently marked as noise or unvisited
                        if self.labels[n_idx] == -1: 
                            neighbors.append(n_idx)
            
            # If the current point is not yet assigned to any cluster, assign it to the current cluster_id
            if self.labels[current_p_idx] == -1:
                self.labels[current_p_idx] = cluster_id
            
            i += 1


    def fit_predict(self, X):
        """
        Performs DBSCAN clustering on the data X.

        Args:
            X (np.array): The data array to be clustered.

        Returns:
            np.array: An array of cluster labels, where -1 indicates noise points.
        """
        n_samples = X.shape[0]
        self.labels = -np.ones(n_samples, dtype=int) # Initialize all points as noise (-1)
        self.visited = set()
        
        cluster_id = 0

        for i in range(n_samples):
            if i in self.visited:
                continue

            self.visited.add(i)
            neighbors = self._get_neighbors(X, i)

            if len(neighbors) < self.min_samples:
                self.labels[i] = -1
            else:
                self._expand_cluster(X, i, list(neighbors), cluster_id)
                cluster_id += 1

        return self.labels