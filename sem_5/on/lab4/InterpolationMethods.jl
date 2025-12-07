# Agnieszka Głuszkiewicz


# Module containing functions for Interpolation exercises
module InterpolationMethods

using Plots

export ilorazyRoznicowe, warNewton, naturalna, rysujNnfx


"""
Task 1: Divided Differences
Calculates the divided differences for Newton interpolation polynomial.

Parameters:
    x   - Vector of nodes
    f   - Vector of function values at nodes

Returns:
    fx  - Vector of calculated divided differences
          fx[1]=f[x0], fx[2]=f[x0, x1], ..., fx[n]=f[x0, ..., xn]
"""
function ilorazyRoznicowe(x::Vector{Float64}, f::Vector{Float64})
    n = length(f)
    # Create a copy to avoid modifying input data
    fx = copy(f)

    # Calculating higher-order differences
    for j in 2:n
        # Iterate backwards to perform in-place updates
        for i in reverse(j:n)
            fx[i] = (fx[i] - fx[i-1]) / (x[i] - x[i-j+1])
        end
    end

    return fx
end


"""
Task 2: Newton Form Evaluation
Calculates the value of the Newton interpolating 
polynomial at point t using generalized Horner's method.

Parameters:
    x   - Vector of nodes
    fx  - Vector of divided differences
    t   - Evaluation point

Returns:
    nt  - Value of the polynomial at point t
"""
function warNewton(x::Vector{Float64}, fx::Vector{Float64}, t::Float64)
    n = length(fx)
    nt = fx[n] # Start with the highest degree coefficient

    # Generalized Horner's scheme loop (backwards)
    for i in reverse(1:n-1)
        nt = fx[i] + (t - x[i]) * nt
    end

    return nt
end


"""
Task 3: Natural Form Coefficients
Calculates coefficients of the natural form of 
the polynomial based on its Newton form coefficients.

Parameters:
    x   - Vector of nodes
    fx  - Vector of divided differences (Newton coefficients)

Returns:
    a   - Vector of natural form coefficients (a0, a1, ..., an)
          such that P(x) = a[1] + a[2]x + ... + a[n+1]x^n
"""
function naturalna(x::Vector{Float64}, fx::Vector{Float64})
    len = length(fx)
    a = copy(fx)

    # Iterate backwards through nodes
    for k in reverse(1:(len-1))
        # Update coefficients for current degree
        for j in k:(len-1)
            a[j] = a[j] - x[k] * a[j+1]
        end
    end

    return a
end


"""
Task 4: Plotting Interpolation
Interpolates function f(x) and plots the result among with the exact function.

Parameters:
    f       - The anonymous function to interpolate
    a       - Start of the interpolation interval
    b       - End of the interpolation interval
    n       - Degree of the polynomial
    wezly   - Type of nodes: :rownoodlegle (equidistant) or :czebyszew (Chebyshev)

Returns:
    Nothing (displays and saves the plot)
"""
function rysujNnfx(f, a::Float64, b::Float64, n::Int; wezly::Symbol = :rownoodlegle)
    
    # node generation
    x_nodes = Vector{Float64}(undef, n + 1)
    
    if wezly == :rownoodlegle
        h = (b - a) / n
        for k in 0:n
            x_nodes[k+1] = a + k * h
        end
    elseif wezly == :czebyszew
        for k in 0:n
            # Chebyshev nodes mapped to [a, b]
            cheb_node = cos((2.0 * k + 1.0) * pi / (2.0 * (n + 1)))
            x_nodes[k+1] = 0.5 * (a + b) + 0.5 * (b - a) * cheb_node
        end
    else
        error("Unknown node type. Use :rownoodlegle or :czebyszew")
    end

    # values and coefficients
    y_nodes = f.(x_nodes)
    diffs = ilorazyRoznicowe(x_nodes, y_nodes)

    # plotting data
    plot_x = range(a, b, length=300)
    plot_y_exact = f.(plot_x)
    plot_y_poly = [warNewton(x_nodes, diffs, t) for t in plot_x]

    # generate plot
    function_name = string(f)
    title_str = "Interpolation: $function_name (n=$n, type=$wezly)"
    plt = plot(plot_x, plot_y_exact, label="Exact f(x)", lw=2, title=title_str, color=:orange)
    plot!(plt, plot_x, plot_y_poly, label="Polynomial p(x)", lw=2, color=:purple)
    scatter!(plt, x_nodes, y_nodes, label="Nodes", markersize=4, markercolor=:purple)

    # save plot to folder
    folder_name = "plots"

    if !isdir(folder_name)
        mkdir(folder_name)
    end
    
    filename_function = replace(function_name, r"[^a-zA-Z0-9_]" => "") 
    if isempty(filename_function) 
        filename_function = "function" 
    end

    filename = "$(folder_name)/$(filename_function)_n$(n)_$(wezly).png"
    
    savefig(plt, filename)
    println("Plot saved: $filename")
    
    display(plt)
end

end