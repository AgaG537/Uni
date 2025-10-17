# Agnieszka Głuszkiewicz


# Correct sum value
const CORRECT_SUM = -1.00657107000000e-11

# Input vectors
x_vector = [2.718281828, -3.141592654, 1.414213562, 0.5772156649, 0.3010299957]
y_vector = [1486.2497, 878366.9879, -22.37492, 4773714.647, 0.000185049]


# (a) "Forward" sum (index 1 to n)
function forward_algorithm(x::Vector{T}, y::Vector{T}) where T
    S = zero(T)
    for i in 1:length(x)
        S += x[i] * y[i]
    end
    return S
end

# (b) "Backward" sum (index n down to 1)
function backward_algorithm(x::Vector{T}, y::Vector{T}) where T
    S = zero(T)
    for i in reverse(1:length(x))
        S += x[i] * y[i]
    end
    return S
end

# (c) Largest to smallest sum
# Sums positive products from max to min, negative products from min to max
function largest_to_smallest_algorithm(x::Vector{T}, y::Vector{T}) where T
    products = [x[i] * y[i] for i in 1:length(x)]
    
    # Positive elements' sorted list (max to min)
    pos_products = sort([p for p in products if p > zero(T)], rev=true)
    # Negative elements' sorted list (min to max)
    neg_products = sort([p for p in products if p < zero(T)], rev=false)
    
    # Sum of positive elements
    S_pos = zero(T)
    for p in pos_products
        S_pos += p
    end
    
    # Sum of negative elements
    S_neg = zero(T)
    for p in neg_products
        S_neg += p
    end
    
    return S_pos + S_neg
end

# (d) Smallest to largest sum
# Sums positive products from min to max, negative products from max to min
function smallest_to_largest_algorithm(x::Vector{T}, y::Vector{T}) where T
    products = [x[i] * y[i] for i in 1:length(x)]
    
    # Positive elements' sorted list (min to max)
    pos_products = sort([p for p in products if p > zero(T)], rev=false)
    # Negative elements' sorted list (max to min)
    neg_products = sort([p for p in products if p < zero(T)], rev=true)
    
    # Sum of positive elements
    S_pos = zero(T)
    for p in pos_products
        S_pos += p
    end
    
    # Sum of negative elements
    S_neg = zero(T)
    for p in neg_products
        S_neg += p
    end
    
    return S_pos + S_neg
end


# Computes absolute and relative errors
function compute_errors(result)
    abs_err = abs(result - CORRECT_SUM) # absolute error
    rel_err = abs_err / abs(CORRECT_SUM) # relative error
    return abs_err, rel_err
end


# Counts and displays the results of the experiment
function run_experiment(T::DataType)
    
    # Convert input vectors to the specified precision (Float32/Float64)
    x = convert(Vector{T}, x_vector)
    y = convert(Vector{T}, y_vector)
    
    # Execute all algorithms and save the results
    result_a = forward_algorithm(x, y)
    result_b = backward_algorithm(x, y)
    result_c = largest_to_smallest_algorithm(x, y)
    result_d = smallest_to_largest_algorithm(x, y)

    # Compute errors
    err_a_abs, err_a_rel = compute_errors(result_a)
    err_b_abs, err_b_rel = compute_errors(result_b)
    err_c_abs, err_c_rel = compute_errors(result_c)
    err_d_abs, err_d_rel = compute_errors(result_d)


    println("\nPrecision Type: $(T)")
    println("Correct sum: $(CORRECT_SUM)\n")
    
    println("Forward:             $(result_a)")
    println("Backward:            $(result_b)")
    println("Largest to smallest: $(result_c)")
    println("Smallest to largest: $(result_d)")

    println("\nErrors (absolute / relative):")
    println("Forward:             $(err_a_abs) / $(err_a_rel)")
    println("Backward:            $(err_b_abs) / $(err_b_rel)")
    println("Largest to smallest: $(err_c_abs) / $(err_c_rel)")
    println("Smallest to largest: $(err_d_abs) / $(err_d_rel)")

end



println("------------ Exercise 5 ------------")

# Single Precision (Float32)
run_experiment(Float32)

# Double Precision (Float64)
run_experiment(Float64)