import sys
import time
import os
import glob
import argparse
from collections import deque

from graph_helpers import read_graph_from_file, generate_parenthesized_tree

DEFAULT_TEST_FOLDER = 'tests'


def bfs(graph):
    n = graph.V
    visited = [False] * (n + 1)
    parent = [0] * (n + 1)
    queue = deque()
    
    order = []
    
    for i in range(1, n + 1): 
        if not visited[i]:
            visited[i] = True
            queue.append(i)
            
            while queue:
                u = queue.popleft()
                order.append(u)
                
                for v in sorted(graph.adj[u]):
                    if not visited[v]:
                        visited[v] = True
                        queue.append(v)
                        parent[v] = u 

    return order, parent


def dfs_recursive(graph):
    n = graph.V
    visited = [False] * (n + 1)
    parent = [0] * (n + 1)
    
    order = []

    def run_dfs_component(u):
        visited[u] = True
        order.append(u)
        
        for v in sorted(graph.adj[u]):
            if not visited[v]:
                parent[v] = u 
                run_dfs_component(v)

    for i in range(1, n + 1): 
        if not visited[i]:
            run_dfs_component(i)
            
    return order, parent



def run_experiment_on_file(file_path, graph, loading_time, alg_choice, include_tree):
    
    start_time = time.perf_counter()
    
    if alg_choice.upper() == 'BFS':
        order, parent_list = bfs(graph)
        alg_name = "BFS"
    elif alg_choice.upper() == 'DFS':
        order, parent_list = dfs_recursive(graph)
        alg_name = "DFS"
    else:
        return 
        
    execution_time = time.perf_counter() - start_time
    
    # Displaying results
    print("-----------------------------------------------------")
    print(f"{os.path.basename(file_path)} : {alg_name}")
    
    print(f"\nVISIT ORDER:")
    
    print(" ".join(map(str, order)))
        
    if include_tree:
        tree_output = generate_parenthesized_tree(parent_list, graph.V)
        print(f"\nSEARCH TREE:")
        print(tree_output)
        

    print("\nRUNNING TIME:")
    print(f"  Loading time: {loading_time:.6f} s")
    print(f"  Execution time {alg_choice.upper()}: {execution_time:.6f} s")
    print("-----------------------------------------------------")


def run_experiment(args):
    
    folder_path = args.folder_path
    include_tree = args.include_tree
    
    file_list = glob.glob(os.path.join(folder_path, '*txt'))
    file_list = [f for f in file_list if os.path.isfile(f)]
    
    if not file_list:
        print(f"No *.txt files found in folder '{folder_path}'.")
        return
    
    for file_path in sorted(file_list):
        
        # Run DFS
        graph_dfs, loading_time_dfs = read_graph_from_file(file_path)
        if graph_dfs:
            run_experiment_on_file(file_path, graph_dfs, loading_time_dfs, 'DFS', include_tree)
            
        # Run BFS
        graph_bfs, loading_time_bfs = read_graph_from_file(file_path)
        if graph_bfs:
            run_experiment_on_file(file_path, graph_bfs, loading_time_bfs, 'BFS', include_tree)


if __name__ == '__main__':
    # Simulating command line call: python ex1.py tests --include-tree
    
    TEST_FOLDER = DEFAULT_TEST_FOLDER

    original_argv = sys.argv[:]
    sys.argv = [original_argv[0], TEST_FOLDER, "--include-tree"]
    
    parser = argparse.ArgumentParser(description="Experimental analysis of DFS and BFS algorithms.")
    parser.add_argument('folder_path', type=str, nargs='?', default=TEST_FOLDER,
                        help="Path to the folder containing graph files (default: tests).")
    parser.add_argument('--include-tree', action='store_true',
                        help="Output the search tree.")
    args = parser.parse_args()
    
    sys.argv = original_argv
    
    run_experiment(args)