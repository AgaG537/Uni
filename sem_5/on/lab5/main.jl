# Agnieszka Głuszkiewicz


include("blocksys.jl")
using .blocksys
using LinearAlgebra

# Configuration constants
const DATA_DIR = "data"
const RESULTS_DIR = "results"

# Matrix sizes to process
const SIZES = ["16", "10000", "50000", "100000", "500000"]

# Ensure results directory exists
if !isdir(RESULTS_DIR)
    mkdir(RESULTS_DIR)
    mkdir(joinpath(RESULTS_DIR, "standard"))
    mkdir(joinpath(RESULTS_DIR, "standard_error"))
    mkdir(joinpath(RESULTS_DIR, "pivot"))
    mkdir(joinpath(RESULTS_DIR, "pivot_error"))
end


# Runs the Gaussian elimination experiment for a list of matrix sizes
#   Inputs: sizes (array of strings), subdir (output subdirectory), use_b_file (bool), pivot (bool)
function run_experiment_suite(sizes::Vector{String}, subdir::String, use_b_file::Bool, pivot::Bool)
    
    num_tests = length(sizes)
    times = Vector{Float64}(undef, num_tests)
    
    # Warmup on the smallest dataset
    path_A = joinpath(DATA_DIR, "Dane" * sizes[1], "A.txt")
    path_b = joinpath(DATA_DIR, "Dane" * sizes[1], "b.txt")
    A_warmup, b_warmup, n_w, l_w = load_matrix_data(path_A, path_b)
    gaussian_elimination(A_warmup, n_w, l_w, pivot, joinpath(RESULTS_DIR, "ignore.txt"), use_b_file ? b_warmup : nothing)


    # Main experiment loop
    for (idx, size_str) in enumerate(sizes)
        println("Processing matrix size: $size_str")
        
        # Construct paths
        path_A = joinpath(DATA_DIR, "Dane" * size_str, "A.txt")
        path_b = joinpath(DATA_DIR, "Dane" * size_str, "b.txt")
        
        # Load Data
        A, b, n, l = load_matrix_data(path_A, path_b)
        
        # Define output file
        output_filename = joinpath(RESULTS_DIR, subdir, size_str * "res.txt")
        
        # Measure time
        start_time = time()
        
        if use_b_file
            gaussian_elimination(A, n, l, pivot, output_filename, b)
        else
            gaussian_elimination(A, n, l, pivot, output_filename)
        end
        
        elapsed = time() - start_time
        times[idx] = elapsed
        
        println(" -> Finished in $elapsed seconds")
    end

    # Save timing results
    open(joinpath(RESULTS_DIR, subdir, "times.txt"), "w") do f
        for (i, t) in enumerate(times)
            println(f, "$t $(sizes[i])")
        end
    end
end


# 1. Standard Gaussian Elimination (calculate x, save vector)
println("\nExperiment 1: Standard Elimination")
run_experiment_suite(SIZES, "standard", true, false)

# 2. Standard Gaussian Elimination (calculate error based on known x)
println("\nExperiment 2: Standard Elimination")
run_experiment_suite(SIZES, "standard_error", false, false)

# 3. Pivoting Gaussian Elimination (calculate x, save vector)
println("\nExperiment 3: Pivoting Elimination")
run_experiment_suite(SIZES, "pivot", true, true)

# 4. Pivoting Gaussian Elimination (calculate error based on known x)
println("\nExperiment 4: Pivoting Elimination")
run_experiment_suite(SIZES, "pivot_error", false, true)