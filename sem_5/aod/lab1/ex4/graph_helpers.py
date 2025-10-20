import sys
import time
from collections import deque

# Using adjacency list
class Graph:
    def __init__(self, n, directed):
        self.V = n
        self.adj = [[] for _ in range(n + 1)] 
        self.directed = directed
        self.E = 0 

    def add_edge(self, u, v):
        self.adj[u].append(v)
        if not self.directed:
            self.adj[v].append(u)


def read_graph_from_file(file_path):
    start_time = time.perf_counter()
    graph = None
    
    try:
        with open(file_path, 'r') as f:
            flag = f.readline().strip().upper()
            if flag not in ['D', 'U']:
                raise ValueError("Error: Invalid graph type flag (expected 'D' or 'U').")

            directed = (flag == 'D')
            n = int(f.readline().strip())
            m = int(f.readline().strip())
            
            graph = Graph(n, directed)

            for line in f:
                line = line.strip()
                if not line: continue
                u, v = map(int, line.split())
                if 1 <= u <= n and 1 <= v <= n:
                    graph.add_edge(u, v)
                
            graph.E = m
            
        loading_time = time.perf_counter() - start_time
        return graph, loading_time

    except Exception as e:
        print(f"Error loading graph from file {file_path}: {e}", file=sys.stderr)
        return None, 0