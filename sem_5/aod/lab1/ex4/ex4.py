import sys
import os
import time
import glob
import argparse
from collections import deque

from graph_helpers import read_graph_from_file 

DEFAULT_TEST_FOLDER = 'tests'


def is_bipartite_bfs(graph):
    n = graph.V
    # color[i] = -1: uncolored, 0: color V0, 1: color V1
    color = [-1] * (n + 1)
    
    partition_V0 = []
    partition_V1 = []
    
    for start_node in range(1, n + 1):
        if color[start_node] == -1:
            queue = deque([start_node])
            color[start_node] = 0
            partition_V0.append(start_node)
            
            while queue:
                u = queue.popleft()
                
                for v in graph.adj[u]:
                    if color[v] == -1:
                        # Assigning the opposite color
                        new_color = 1 - color[u]
                        color[v] = new_color
                        queue.append(v)
                        
                        if new_color == 0:
                            partition_V0.append(v)
                        else:
                            partition_V1.append(v)
                            
                    elif color[v] == color[u]:
                        return False, [], []
    
    partition_V0.sort()
    partition_V1.sort()
    
    return True, partition_V0, partition_V1



def run_experiment_on_file(file_path, graph, loading_time):
    
    if not graph:
        print(f"--- {os.path.basename(file_path)}: Skipped (loading error). ---")
        return

    start_time = time.perf_counter()
    is_bipartite, V0, V1 = is_bipartite_bfs(graph)
    execution_time = time.perf_counter() - start_time
    
    # Displaying results
    print("-----------------------------------------------------")
    print(f"File: {os.path.basename(file_path)}")
    
    print("\nBIPARTITE RESULT:")
    if is_bipartite:
        print("The graph IS bipartite")
    else:
        print("The graph IS NOT bipartite")
    
    print("\nPARTITION DETAILS:")
    
    if is_bipartite:
        if graph.V <= 200:
            print(f"|V0| = {len(V0)}, V0: {' '.join(map(str, V0))}")
            print(f"|V1| = {len(V1)}, V1: {' '.join(map(str, V1))}")
        else:
            print(f"|V0| = {len(V0)}")
            print(f"|V1| = {len(V1)}")

    print("\nRUNNING TIME:")
    print(f"  Loading time: {loading_time:.6f} s")
    print(f"  Execution time: {execution_time:.6f} s")
    print("-----------------------------------------------------")


def run_experiment(args):
    
    folder_path = args.folder_path
    
    file_list = glob.glob(os.path.join(folder_path, '*.txt'))
    file_list.sort() 
    
    if not file_list:
        print(f"No *.txt files found in folder '{folder_path}'.")
    
    for file_path in file_list:
        graph, loading_time = read_graph_from_file(file_path)
        if graph:
             run_experiment_on_file(file_path, graph, loading_time)

    print("Implemented algorithm (BFS coloring) complexity: O(|V| + |E|).")


if __name__ == '__main__':
    # Simulating command line call: python ex3.py tests
    
    TEST_FOLDER = DEFAULT_TEST_FOLDER
    
    original_argv = sys.argv[:]
    sys.argv = [original_argv[0], TEST_FOLDER] 
    
    parser = argparse.ArgumentParser(description="Implementation of Bipartite Graph Check using BFS Coloring.")
    parser.add_argument('folder_path', type=str, nargs='?', default=TEST_FOLDER,
                        help="Path to the folder containing graph files (default: tests).")
    args = parser.parse_args()
    
    sys.argv = original_argv
    
    run_experiment(args)