# Agnieszka Głuszkiewicz


module blocksys

using DelimitedFiles
using SparseArrays
using LinearAlgebra

export load_matrix_data
export gaussian_elimination

# Loads the matrix A and optional vector b from files
#   Inputs: matrix_file (path to A), vector_file (path to b, optional)
#   Outputs: A (SparseMatrix), b (Vector), n (size), l (block size)
function load_matrix_data(matrix_file::String, vector_file::Union{String, Nothing}=nothing)
    n = 0
    l = 0
    rows = Vector{Float64}(undef, 0)
    cols = Vector{Float64}(undef, 0)
    vals = Vector{Float64}(undef, 0)

    # Reading matrix A
    open(matrix_file, "r") do f
        # Read dimensions
        header = readdlm(IOBuffer(readuntil(f, "\n")))
        n = Int64(header[1])
        l = Int64(header[2])

        # Read non-zero elements
        while !eof(f)
            line_data = readdlm(IOBuffer(readuntil(f, "\n")))
            push!(rows, line_data[1])
            push!(cols, line_data[2])
            push!(vals, line_data[3])
        end    
    end

    A = sparse(rows, cols, vals, n, n)  
    
    # Return if no vector b is provided
    if vector_file === nothing
        return A, nothing, n, l
    end

    # Reading Vector b
    b = Vector{Float64}(undef, 0)
    open(vector_file, "r") do f
        readuntil(f, "\n")
        while !eof(f)
            line_data = readdlm(IOBuffer(readuntil(f, "\n")))
            push!(b, line_data[1])
        end  
    end
    
    return A, b, n, l
end

# Performs Gaussian elimination optimized for the specific block structure
#   Inputs: A (sparse matrix), n (size), l (block size), use_pivoting (bool), output_file (path), b (rhs vector)
#   Outputs: Writes solution or error to file
function gaussian_elimination(A::SparseMatrixCSC, n::Int, l::Int, use_pivoting::Bool, output_file::String, b::Union{Vector{Float64}, Nothing}=nothing)
    
    # If b is not provided, generate it based on x = [1, ..., 1]
    calculate_error = false
    if b === nothing
        x_exact = ones(n)
        b = A * x_exact
        calculate_error = true
    end

    current_b = copy(b)
    
    # Elimination phase
    for k in 1:n-1        
        # Calculate the limit to avoid processing zeros
        limit = min(n, k + 2 * l - (k % l))

        # Partial Pivoting (if enabled)
        if use_pivoting
            max_val = 0.0
            p = k
            for i in k:limit
                if abs(A[i, k]) > max_val
                    max_val = abs(A[i, k])
                    p = i
                end
            end

            if p != k
                # Swap rows in vector b
                current_b[k], current_b[p] = current_b[p], current_b[k]
                # Swap rows in matrix A
                for i in k:limit
                    A[k, i], A[p, i] = A[p, i], A[k, i]
                end
            end
        end

        # Elimination
        for i in k+1:limit
            multiplier = A[i, k] / A[k, k]
            for j in k:limit
                A[i, j] = A[i, j] - multiplier * A[k, j]
            end
            current_b[i] = current_b[i] - multiplier * current_b[k]
        end
    end

    # Count results
    result_x = Vector{Float64}(undef, n)
    result_x[n] = current_b[n] / A[n, n]
    
    for k in n-1:-1:1
        sum_val = 0.0
        limit = min(k + 2 * l - (k % l), n)
        for j in k+1:limit
            sum_val += A[k, j] * result_x[j]
        end
        result_x[k] = (current_b[k] - sum_val) / A[k, k]
    end

    # Saving results
    open(output_file, "a") do f
        if calculate_error
            x_exact = ones(n)
            # Calculate relative error
            rel_error = norm(result_x - x_exact) / norm(x_exact)
            println(f, rel_error)
        else
            # Save the solution vector
            for val in result_x
                println(f, val)
            end
        end
    end
end

end