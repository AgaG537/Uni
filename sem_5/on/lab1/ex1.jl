# Agnieszka Głuszkiewicz


# Calculates the machine epsilon (macheps) iteratively: the smallest epsilon such that fl(1.0 + epsilon) > 1.0
# T: The floating-point data type (here: Float16, Float32, Float64)
function calculate_macheps(T::DataType)
    eps_candidate = T(1.0) # Current candidate for macheps

    while T(1.0) + eps_candidate > T(1.0)
        eps_candidate = eps_candidate / T(2.0)
    end
    
    return eps_candidate * T(2.0)
end

# Calculates eta (MINsub) iteratively: the smallest positive non-zero machine number
# T: The floating-point data type
function calculate_eta(T::DataType)
    eta_candidate = T(1.0) # Current candidate for eta

    while eta_candidate / T(2.0) > T(0.0)
        eta_candidate = eta_candidate / T(2.0)
    end
    
    return eta_candidate
end

# Calculates MAX iteratively: the largest finite machine number before Inf
# T: The floating-point data type
function calculate_floatmax(T::DataType)
    # 1) Finding 2^E_max

    # Stores the largest power of 2 (2^E_max) that can be represented as a finite number of type T
    max_exp_val = T(1.0)
    while !isinf(max_exp_val * T(2.0))
        max_exp_val *= T(2.0)
    end
    
    # 2) Filling the mantissa using a logarithmic iteration

    # The calculated value, starting from 2^E_max and accumulating the mantissa bits
    current_val = max_exp_val
    # Represents the value of the current mantissa bit being tested
    current_bit = max_exp_val / T(2.0)

    while !isinf(current_val + current_bit) && current_bit > T(0.0) 
        current_val += current_bit
        current_bit /= T(2.0)
    end
    
    return current_val
end


println("------------ Exercise 1 ------------")

for T in [Float16, Float32, Float64]
    println("\nType: $T")
    println("-"^20)

    # macheps
    macheps_iter = calculate_macheps(T)
    macheps_func = eps(T)
    println("Macheps:")
    println("  Iterative: $macheps_iter")
    println("  Function:  $macheps_func")
    println("  Match:     $(macheps_iter == macheps_func)")

    # eta
    eta_iter = calculate_eta(T)
    eta_func = nextfloat(T(0.0))
    minnor_func = floatmin(T)
    println("Eta (MINsub):")
    println("  Iterative: $eta_iter")
    println("  Function:  $eta_func")
    println("  Match:     $(eta_iter == eta_func)")
    println("  MINnor (floatmin): $minnor_func")

    # MAX
    x_iter = calculate_floatmax(T)
    x_func = floatmax(T)
    println("MAX (Largest Finite):")
    println("  Iterative: $x_iter")
    println("  Function:  $x_func")
    println("  Match:     $(x_iter == x_func)")
end