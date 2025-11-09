# Agnieszka Głuszkiewicz


using LinearAlgebra

# Defines the recurrence relation for the logistic model
#   Inputs: p_n (current population), r (growth rate)
#   Outputs: p_{n+1} (the next population value)
function logistic_model(p_n::AbstractFloat, r::AbstractFloat)
    return p_n + r * p_n * (1 - p_n)
end


# Runs the logistic model iteration for a given precision type
#   Inputs: p0, r, max_iter, precision (described in parameters section)
#   Outputs: Array of population values [p0, p1, p2, ..., p_max_iter]
function run_standard_experiment(p0, r, max_iter, precision)
    # Convert parameters to required precision
    p_n = precision(p0)
    r_val = precision(r)
    
    results = [p_n]
    
    # n: Current iteration index
    for n in 1:max_iter
        p_n = precision(logistic_model(p_n, r_val))
        push!(results, p_n)
    end
    return results
end


# Runs the logistic model in Float32 with a perturbation at a specific iteration (n=10)
#   Inputs: p0, r, max_iter, cutoff_iter (described in parameters section)
#   Outputs: Array of population values [p0, p1, p2, ..., p_max_iter]
function run_perturbed_experiment(p0, r, max_iter, cutoff_iter)
    precision = Float32
    # Convert parameters to required precision
    p_n = precision(p0)
    r_val = precision(r)
    
    results = [p_n]
    
    # n: Current iteration index
    for n in 1:max_iter
        p_n = precision(logistic_model(p_n, r_val))
        if n == cutoff_iter
            p_n = round(p_n, RoundDown, digits=3)
        end
        push!(results, p_n)
    end
    return results
end


# --- Parameters ---
P0 = 0.01               # Initial population size
R = 3.0                 # Growth rate constant
MAX_ITER = 40           # Total number of iterations to perform
CUTOFF_ITER = 10        # The iteration number where the cutoff is applied

# --- (1) Value cutoff experiment (Float32) ---
# Baseline/perturbed results array in Float32
results_f32_base = run_standard_experiment(P0, R, MAX_ITER, Float32)
results_f32_pert = run_perturbed_experiment(P0, R, MAX_ITER, CUTOFF_ITER)

# --- (2) Precision comparison experiment ---
# Baseline results array in Float64
results_f64_base = run_standard_experiment(P0, R, MAX_ITER, Float64)



# --- Reporting Results ---

println("------------ Exercise 5 ------------")


println("\nExperiment 1: Float32 Perturbation (Cutoff at n=$CUTOFF_ITER)")

# n: Iteration index for reporting
for n in 0:MAX_ITER
    # Population value from the standard/perturbated Float32 run at iteration n
    p_base = results_f32_base[n+1]
    p_pert = results_f32_pert[n+1]
    
    # Absolute difference
    diff_pert = abs(p_base - p_pert)

    println("n=$n | F32 Base: $p_base | F32 Perturb: $p_pert | Diff(|Base - Perturb|): $diff_pert")
end


println("\nExperiment 2: Precision Comparison (F32 vs F64)")

for n in 0:MAX_ITER
    # Population value from the standard Float32\64 run at iteration n
    p_f32 = results_f32_base[n+1]
    p_f64 = results_f64_base[n+1]
    
    # Absolute difference between the two precisions
    diff = abs(p_f64 - p_f32)
    
    println("n=$n | F32: $p_f32 | F64: $p_f64 | Diff(|F64 - F32|): $diff")
end