import sys
import os
from utils import read_text_from_file, get_alphabet

# -------------------- Finite Automata (FA) Algorithm --------------------

def compute_transition_function(P, E):
    m = len(P)
    delta = {q: {a: 0 for a in E} for q in range(m + 1)} 
    
    for q in range(m + 1):
        for a in E:
            k = min(m, q + 1)
            text_to_check = P[:q] + a
            
            # Search for the largest k such that P[:k] is a suffix of P[:q]a
            while not(text_to_check.endswith(P[:k]) or k == 0):
                k = k - 1
            
            delta[q][a] = k
    return delta

def FA_matcher(T, P, delta, m):
    n = len(T)
    q = 0 # Current state
    
    for i in range(n):
        if T[i] in delta[q]:
            q = delta[q][T[i]]
        else:
            q = 0 

        if q == m:
            print("Pattern occurs with shift", i - m + 1)


# -------------------- Main --------------------

def main():
    if len(sys.argv) != 3:
        print("Usage:")
        print("  python3 FA.py <pattern> <filename>")
        sys.exit(1)

    pattern = sys.argv[1]
    filename = sys.argv[2]

    if not os.path.exists(filename):
        print(f"Error: File '{filename}' does not exist.", file=sys.stderr)
        sys.exit(1)

    text = read_text_from_file(filename)
    m = len(pattern)

    if m == 0:
        print("Error: Pattern cannot be empty.")
        sys.exit(1)
        
    E = get_alphabet(pattern, text)
    delta = compute_transition_function(pattern, E)
    FA_matcher(text, pattern, delta, m)

if __name__ == "__main__":
    main()