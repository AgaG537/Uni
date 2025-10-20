import sys
import time
import os
import glob
import argparse
from collections import deque

from graph_helpers import read_graph_from_file

sys.setrecursionlimit(3000)

DEFAULT_TEST_FOLDER = 'tests'


# Colors (state): 
# 0 (White): Unvisited
# 1 (Gray): Visiting - on recursion stack
# 2 (Black): Processed
def topological_sort_dfs(graph):
    n = graph.V
    if not graph.directed:
        return False, [] 
        
    color = [0] * (n + 1)
    topological_order = deque()
    has_cycle = False

    def dfs_visit(u):
        nonlocal has_cycle
        if has_cycle:
            return
            
        color[u] = 1
        
        for v in sorted(graph.adj[u]):
            if color[v] == 1:
                has_cycle = True
                return
            
            if color[v] == 0:
                dfs_visit(v)
        
        color[u] = 2
        topological_order.appendleft(u)

    for i in range(1, n + 1):
        if color[i] == 0 and not has_cycle:
            dfs_visit(i)
            
    return has_cycle, list(topological_order)



def run_experiment_on_file(file_path, graph, loading_time):
    
    if not graph:
        print(f"{os.path.basename(file_path)}: Skipped (loading error).")
        return
    
    if not graph.directed:
        print(f"{os.path.basename(file_path)}: Skipped (Graph must be directed).")
        return

    start_time = time.perf_counter()
    has_cycle, topo_order = topological_sort_dfs(graph)
    execution_time = time.perf_counter() - start_time
    
    # Displaying results
    print("-----------------------------------------------------")
    print(f"{os.path.basename(file_path)}")
    
    print("\nCYCLE DETECTION:")
    if has_cycle:
        print("Graph contains a cycle")
    else:
        print("No cycle")
    
    if not(has_cycle) and graph.V <= 200:
        print("\nTOPOLOGICAL ORDER:")
        print(" ".join(map(str, topo_order)))

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
        if graph and graph.directed:
             run_experiment_on_file(file_path, graph, loading_time)
        elif graph and not graph.directed:
             print(f"--- {os.path.basename(file_path)}: Skipped (Graph must be directed 'D'). ---")

if __name__ == '__main__':
    # Simulating command line call: python ex2.py tests

    TEST_FOLDER = DEFAULT_TEST_FOLDER 

    original_argv = sys.argv[:]
    sys.argv = [original_argv[0], TEST_FOLDER]
    
    parser = argparse.ArgumentParser(description="Implementation of Topological Sort with cycle detection.")
    parser.add_argument('folder_path', type=str, nargs='?', default=TEST_FOLDER,
                        help="Path to the folder containing directed graph files (default: tests).")
    args = parser.parse_args()
    
    sys.argv = original_argv
    
    run_experiment(args)