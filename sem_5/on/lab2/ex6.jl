# Agnieszka Głuszkiewicz


using LinearAlgebra
using Plots

# Defines the recurrence relation: x_{n+1} = x_n^2 + c
#   Inputs: x_n (the current value), c (the constant parameter)
#   Outputs: x_{n+1} (the next value)
function recurrence_relation(x_n::T, c::T) where T <: AbstractFloat
    return x_n^2 + c
end

# Performs iterations of the quadratic recurrence relation in Float64
#   Inputs: c (constant parameter), x0 (initial condition), max_iter (total iterations)
#   Outputs: Returns the array of calculated values [x0, x1, ..., x_max_iter]
function run_recurrence_experiment(c::Float64, x0::Float64, max_iter::Int)
    x_n = x0            # The current state value
    c_val = c           # The constant parameter
    results = [x_n]     # Array storing the entire sequence, including x0

    # n: Current iteration index
    for n in 1:max_iter
        x_n = recurrence_relation(x_n, c_val)
        push!(results, x_n)
    end
    return results
end

# Array of tuples defining (c, x0, title) for each case
experiments = [
    (-2.0, 1.0, "Case 1: c=-2, x0=1"),
    (-2.0, 2.0, "Case 2: c=-2, x0=2"),
    (-2.0, 1.99999999999999, "Case 3: c=-2, x0=1.999..."),
    (-1.0, 1.0, "Case 4: c=-1, x0=1"),
    (-1.0, -1.0, "Case 5: c=-1, x0=-1"),
    (-1.0, 0.75, "Case 6: c=-1, x0=0.75"),
    (-1.0, 0.25, "Case 7: c=-1, x0=0.25")
]

# The maximum number of steps to calculate
MAX_ITER = 40



# --- Execution and Reporting ---
println("------------ Exercise 6 ------------")

# Create plots directory if it doesn't exist
if !isdir("plots_ex6")
    mkdir("plots_ex6")
end

# idx: Index for file naming. c: parameter, x0: initial condition, title: case description
for (idx, (c, x0, title)) in enumerate(experiments)
    results = run_recurrence_experiment(c, x0, MAX_ITER)
    
    println("\n------------------------------------------")
    println("$title")
    println("------------------------------------------")
    
    # Printing states
    for n in 0:MAX_ITER
        if n + 1 > length(results) 
            break
        end
        # The value at iteration n
        x_n = results[n + 1]
        println("n=$n | x(n): $x_n")
    end

    # --- Plotting Section: Cobweb Plot ---
    
    # 1. Determine Plotting Range 
    # Filtered array containing only finite numbers
    finite_results = filter(isfinite, results)
    
    # Calculate min/max range based on sequence values
    min_x_val = floor(min(-2.5, minimum(finite_results) - 0.5))
    max_x_val = ceil(max(2.5, maximum(finite_results) + 0.5))
    
    # Dense array of x-values
    x_range_cobweb = LinRange(min_x_val, max_x_val, 500)
    
    # 2. Define the functions
    f(x) = x^2 + c      # The recurrence function f(x)
    y_eq_x(x) = x       # The diagonal line y = x
    
    # 3. Create the plot
    p_cobweb = plot(x_range_cobweb, f, 
             label="f(x) = x^2 + $c", 
             xlabel="x(n)", 
             ylabel="x(n+1)", 
             title="Recurrence Cobweb Plot: c=$c, x₀=$x0", 
             linewidth=2, 
             linecolor=:purple, 
             legend=:topleft)
             
    plot!(p_cobweb, x_range_cobweb, y_eq_x, 
          label="y = x", 
          linewidth=1.5, 
          linestyle=:dash, 
          linecolor=:orange)

    # 4. Add the cobweb lines
    for i in 1:length(finite_results)-1
        x_n = finite_results[i]
        x_n_plus_1 = finite_results[i+1]

        # Plot vertical line from (x_n, x_n) to (x_n, x_{n+1}) (on f(x))
        plot!(p_cobweb, [x_n, x_n], [x_n, x_n_plus_1],
              linecolor=:black, linewidth=0.8, label="")

        # Plot horizontal line from (x_n, x_{n+1}) to (x_{n+1}, x_{n+1}) (on y=x)
        plot!(p_cobweb, [x_n, x_n_plus_1], [x_n_plus_1, x_n_plus_1],
              linecolor=:black, linewidth=0.8, label="")
    end

    # Mark the initial point
    scatter!(p_cobweb, [x0], [x0], label="x₀ = $x0", marker=:circle, markersize=3, markercolor=:black)

    # Save the plot
    plot_filename = "plots_ex6/$(idx)_plot_c=$(c)_x0=$(x0).png"
    savefig(p_cobweb, plot_filename)
    println("Plot saved to: $plot_filename")
end