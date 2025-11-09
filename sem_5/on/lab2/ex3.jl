# Agnieszka Głuszkiewicz


using LinearAlgebra

function hilb(n::Int)
# Function generates the Hilbert matrix  A of size n,
#  A (i, j) = 1 / (i + j - 1)
# Inputs:
#  n: size of matrix A, n>=1
#
#
# Usage: hilb(10)
#
# Pawel Zielinski
        if n < 1
         error("size n should be >= 1")
        end
        return [1 / (i + j - 1) for i in 1:n, j in 1:n]
end

function matcond(n::Int, c::Float64)
# Function generates a random square matrix A of size n with
# a given condition number c.
# Inputs:
#  n: size of matrix A, n>1
#  c: condition of matrix A, c>= 1.0
#
# Usage: matcond(10, 100.0)
#
# Pawel Zielinski
        if n < 2
         error("size n should be > 1")
        end
        if c< 1.0
         error("condition number  c of a matrix  should be >= 1.0")
        end
        (U,S,V)=svd(rand(n,n))
        return U*diagm(0 =>[LinRange(1.0,c,n);])*V'
end


# Solves Ax=b, calculates errors, and prints results
# Inputs:
#   A: Matrix of coefficients
#   b: Right-hand side vector
#   x: The known exact solution vector
#   target_c: Optional target condition number for random matrices
function solve_and_report(A, b, x; target_c=nothing)
    n = size(A, 1)

    # Calculate solutions
    x_gauss = A \ b
    x_inv = inv(A) * b

    # Calculate errors and matrix properties
    err_gauss = norm(x_gauss - x) / norm(x)
    err_inv = norm(x_inv - x) / norm(x)
    cond_A = cond(A)
    rank_A = rank(A)

    # Decide whether to print target_c
    prefix = target_c === nothing ? "n=$n" : "n=$n | c_target=$(target_c)"

    println("$prefix | Cond(A)=$(cond_A) | Rank(A)=$(rank_A) | Err_Gauss: $(err_gauss) | Err_Inv: $(err_inv)")
end


# Generates Hilbert matrices from n=2 up to max_n, solves Ax=b, and reports errors
function hilbert_matrices_report(max_n::Int)
    println("--- Experiment A: Hilbert Matrices (Hn) ---")

    for n in 2:max_n 
        A = hilb(n)
        x = ones(Float64, n)
        b = A * x
        
        solve_and_report(A, b, x)
    end
end


# Generates random conditioned matrices for given sizes and condition numbers, solves Ax=b, and reports errors
function random_matrices_report(n_sizes::Array{Int}, c_conditions::Array{Float64})
    println("\n--- Experiment B: Conditioned Random Matrices (Rn) ---")
    
    for n in n_sizes
        for c in c_conditions
            A = matcond(n, c) 
            x = ones(Float64, n)
            b = A * x
            
            solve_and_report(A, b, x, target_c=c)
        end
    end
end


# --- Execution of the experiment ---

# Required arrays
matrix_sizes = [5, 10, 20]
condition_numbers = [1.0, 10.0, 1e3, 1e7, 1e12, 1e16]

println("------------ Exercise 3 ------------")

# Experiment A: Hn
hilbert_matrices_report(10) 

# Experiment B: Rn
random_matrices_report(matrix_sizes, condition_numbers)