import sys
import os
from utils import read_text_from_file

# -------------------- Knuth-Morris-Pratt (KMP) Algorithm --------------------

def compute_prefix_function(P):
    m = len(P)
    pi = [0] * m
    k = 0 # Length of the current longest prefix suffix
    
    for q in range(1, m):
        while k > 0 and P[k] != P[q]:
            k = pi[k - 1]
            
        if P[k] == P[q]:
            k += 1
            
        pi[q] = k
        
    return pi


def KMP_matcher(T, P):
    m = len(P)

    if m == 0:
        return
    
    n = len(T)
    pi = compute_prefix_function(P)
    q = 0 # Length of the current matched prefix (state)
    
    for i in range(n):
        # Mismatch: use the prefix function to reset state q
        while q > 0 and P[q] != T[i]:
            q = pi[q - 1]
            
        # Match
        if P[q] == T[i]:
            q += 1
            
        if q == m:
            print("Pattern occurs with shift", i - m + 1)
            q = pi[q - 1]


# -------------------- Main --------------------

def main():
    if len(sys.argv) != 3:
        print("Usage:")
        print("  python3 KMP.py <pattern> <filename>")
        sys.exit(1)

    pattern = sys.argv[1]
    filename = sys.argv[2]

    if not os.path.exists(filename):
        print(f"Error: File '{filename}' does not exist.", file=sys.stderr)
        sys.exit(1)

    text = read_text_from_file(filename)
    
    if len(pattern) == 0:
        print("Error: Pattern cannot be empty.")
        sys.exit(1)

    KMP_matcher(text, pattern)


if __name__ == "__main__":
    main()