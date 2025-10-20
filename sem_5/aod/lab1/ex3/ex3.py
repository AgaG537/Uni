import sys
import os
import time
import glob
import argparse

from graph_helpers import Graph, read_graph_from_file 

sys.setrecursionlimit(3000000) 

DEFAULT_TEST_FOLDER = 'tests'


def transpose_graph(graph):
    n = graph.V
    graph_t = Graph(n, directed=True)
    graph_t.E = graph.E
    
    for u in range(1, n + 1):
        for v in graph.adj[u]:
            # Adding edge v -> u in G^T
            graph_t.adj[v].append(u)
            
    return graph_t


def kosaraju_scc(graph):
    n = graph.V
    
    # First DFS - computing finishing times
    visited = [False] * (n + 1)
    finish_stack = [] 

    def dfs_visit_1(u):
        visited[u] = True
        for v in graph.adj[u]:
            if not visited[v]:
                dfs_visit_1(v)
        finish_stack.append(u) 

    for i in range(1, n + 1):
        if not visited[i]:
            dfs_visit_1(i)
            
    # Transposing the graph
    graph_t = transpose_graph(graph)

    # Second DFS
    visited = [False] * (n + 1)
    sccs = [] 

    def dfs_visit_2(u, current_scc):
        visited[u] = True
        current_scc.append(u)
        
        for v in sorted(graph_t.adj[u]):
            if not visited[v]:
                dfs_visit_2(v, current_scc)

    for u in reversed(finish_stack):
        if not visited[u]:
            current_scc = []
            dfs_visit_2(u, current_scc)
            
            current_scc.sort()
            sccs.append(current_scc)
            
    return sccs



def run_experiment_on_file(file_path, graph, loading_time):
    
    if not graph:
        print(f"--- {os.path.basename(file_path)}: Skipped (loading error). ---")
        return
    
    if not graph.directed:
        print(f"--- {os.path.basename(file_path)}: Skipped (Graph must be directed). ---")
        return

    start_time = time.perf_counter()
    sccs = kosaraju_scc(graph)
    execution_time = time.perf_counter() - start_time
    
    # Displaying results
    print("-----------------------------------------------------")
    print(f"File: {os.path.basename(file_path)}\n")
    
    if graph.V <= 200:
        for i, scc in enumerate(sccs, 1):
            size = len(scc)
            print(f"Component {i}: Size = {size}, Vertices: {' '.join(map(str, scc))}")
    else:
        for i, scc in enumerate(sccs, 1):
            size = len(scc)
            print(f"Component {i}: Size = {size}")

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
    # Simulating command line call: python ex3.py tests

    TEST_FOLDER = DEFAULT_TEST_FOLDER
    
    original_argv = sys.argv[:]
    sys.argv = [original_argv[0], TEST_FOLDER] 
    
    parser = argparse.ArgumentParser(description="Implementation of Strongly Connected Components (SCC) using Kosaraju's Algorithm.")
    parser.add_argument('folder_path', type=str, nargs='?', default=TEST_FOLDER,
                        help="Path to the folder containing directed graph files (default: tests).")
    args = parser.parse_args()
    
    sys.argv = original_argv
    
    run_experiment(args)