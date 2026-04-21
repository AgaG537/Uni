import random
import os
import matplotlib.pyplot as plt
import tsplib95

DATA_FILES = {
    'Western Sahara': 'wi29.tsp',
    'Djibouti': 'dj38.tsp',
    'Qatar': 'qa194.tsp',
    'Uruguay': 'uy734.tsp',
    'Zimbabwe': 'zi929.tsp'
}

def calc_tour_length(tour, problem):
    """
    Calculates the total length of a Hamiltonian cycle.
    Uses tsplib95's get_weight to handle distances and rounding automatically.
    """
    length = 0
    n = len(tour)
    for i in range(n):
        length += problem.get_weight(tour[i], tour[(i + 1) % n])
    return length

def prim_mst(problem):
    """
    Computes the Minimum Spanning Tree (MST) using Prim's algorithm.
    Utilizes tsplib95 for edge weights.
    Returns: (mst_weight, list_of_edges, adjacency_list)
    """
    node_ids = list(problem.get_nodes())
    start_node = node_ids[0]
    
    unvisited = set(node_ids)
    unvisited.remove(start_node)
    
    # Store minimum distance to the current tree and the parent node
    min_dist = {nid: problem.get_weight(start_node, nid) for nid in unvisited}
    parent = {nid: start_node for nid in unvisited}
    
    mst_weight = 0
    mst_edges = []
    mst_adj = {nid: [] for nid in node_ids}
    
    while unvisited:
        # Find the unvisited node closest to the tree
        best_node = min(unvisited, key=lambda nid: min_dist[nid])
        unvisited.remove(best_node)
        
        p = parent[best_node]
        w = min_dist[best_node]
        
        # Add the new node to the tree
        mst_weight += w
        mst_edges.append((p, best_node))
        mst_adj[p].append(best_node)
        mst_adj[best_node].append(p)
        
        # Update distances to the remaining unvisited nodes
        for nid in unvisited:
            d = problem.get_weight(best_node, nid)
            if d < min_dist[nid]:
                min_dist[nid] = d
                parent[nid] = best_node
                
    return mst_weight, mst_edges, mst_adj

def dfs_tsp_tour(mst_adj, start_node):
    """
    Generates a TSP tour by traversing the MST using Depth-First Search (DFS).
    Records nodes in the order of their first visit (pre-order).
    """
    visited = set()
    tour = []
    stack = [start_node]
    
    while stack:
        u = stack.pop()
        if u not in visited:
            visited.add(u)
            tour.append(u)
            # Add neighbors to stack (reversed for standard DFS visit order)
            for v in reversed(mst_adj[u]):
                if v not in visited:
                    stack.append(v)
    return tour

def plot_tour_to_file(tour, node_coords, title, filename, is_mst=False):
    """
    Generates a plot for either a tour or an MST and saves it to a PNG file.
    Ensures consistent visual style across all plots.
    """
    plt.figure(figsize=(10, 6))
    
    # Plot all nodes
    all_x = [node_coords[n][0] for n in node_coords]
    all_y = [node_coords[n][1] for n in node_coords]
    plt.scatter(all_x, all_y, s=8, color='navy', zorder=5)
    
    if is_mst:
        # Plot MST edges
        for p1_id, p2_id in tour:
            x = [node_coords[p1_id][0], node_coords[p2_id][0]]
            y = [node_coords[p1_id][1], node_coords[p2_id][1]]
            plt.plot(x, y, linestyle='-', markersize=0, color='blue', linewidth=1.5, zorder=2)
    else:
        # Plot standard tour (closed cycle)
        x = [node_coords[n][0] for n in tour]
        y = [node_coords[n][1] for n in tour]
        x.append(node_coords[tour[0]][0])
        y.append(node_coords[tour[0]][1])
        
        plt.plot(x, y, linestyle='-', markersize=0, color='blue', linewidth=1.5, zorder=2)
        
        # Highlight the starting point
        plt.plot(x[0], y[0], marker='o', markersize=6, color='navy', label='Start', zorder=6)
        plt.legend()
    
    plt.title(title)
    plt.xlabel('X Coordinate')
    plt.ylabel('Y Coordinate')
    plt.grid(True, linestyle=':', alpha=0.7, color='gray')
    plt.tight_layout()
    
    filepath = os.path.join('plots1', filename)
    plt.savefig(filepath, dpi=300)
    plt.close()

def main():
    n_draws = 1000
    os.makedirs('plots1', exist_ok=True)
    
    for country_name, filename in DATA_FILES.items():
        print(f"\n{country_name}:")
        
        if not os.path.exists(filename):
            print(f"File '{filename}' not found. Skipping.")
            continue
            
        # Load the problem using tsplib95
        problem = tsplib95.load(filename)
        node_ids = list(problem.get_nodes())
        node_coords = problem.node_coords
        
        costs = []
        best_tour = None
        best_cost = float('inf')
        
        # Generate 1000 random permutations
        for _ in range(n_draws):
            tour = node_ids.copy()
            random.shuffle(tour)
            
            cost = calc_tour_length(tour, problem)
            costs.append(cost)
            
            # Save the global minimum
            if cost < best_cost:
                best_cost = cost
                best_tour = tour.copy()
                
        # Calculate chunk averages (Tasks 1a and 1b)
        chunk_mins_10 = [min(costs[i:i + 10]) for i in range(0, n_draws, 10)]
        avg_min_10 = sum(chunk_mins_10) / len(chunk_mins_10)
        
        chunk_mins_50 = [min(costs[i:i + 50]) for i in range(0, n_draws, 50)]
        avg_min_50 = sum(chunk_mins_50) / len(chunk_mins_50)
        
        # Tasks 3 & 4: MST and 2-Approximation using DFS
        mst_weight, mst_edges, mst_adj = prim_mst(problem)
        dfs_tour = dfs_tsp_tour(mst_adj, node_ids[0])
        dfs_tour_weight = calc_tour_length(dfs_tour, problem)
        
        # Show results
        print(f"(1a) Average minimum (groups of 10): {avg_min_10:.2f}")
        print(f"(1b) Average minimum (groups of 50): {avg_min_50:.2f}")
        print(f"(1c) Global minimum (1000 runs):     {best_cost}")
        print(f"(3)  MST weight:                     {mst_weight}")
        print(f"(4)  DFS 2-approximation weight:     {dfs_tour_weight}")
        print(f"     -> Ratio (Cycle / MST):         {dfs_tour_weight / mst_weight:.2f}")
        
        safe_name = country_name.lower().replace(' ', '_')
        
        plot_tour_to_file(best_tour, node_coords, 
                          f"{country_name} - Global Minimum (1000 runs)", 
                          f"{safe_name}_1c_min1000.png")
                          
        plot_tour_to_file(dfs_tour, node_coords, 
                          f"{country_name} - MST 2-Approximation (Weight: {dfs_tour_weight})", 
                          f"{safe_name}_4_dfs_aprox.png")

if __name__ == "__main__":
    main()