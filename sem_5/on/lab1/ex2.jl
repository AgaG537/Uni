# Agnieszka Głuszkiewicz


# Checks Kahan's identity for calculating machine epsilon: 3 * (4/3 - 1) - 1
# T: The floating-point data type
function kahan_macheps(T::DataType)
    
    # Calculated Kahan expression
    kahan_result = T(3.0) * (T(4.0) / T(3.0) - T(1.0)) - T(1.0)
    
    # Standard machine epsilon
    macheps_func = eps(T)

    println("Type: $T")
    println("  Kahan Result:    $(kahan_result)")
    println("  Function eps(T): $(macheps_func)")
    println("  Match:           $(kahan_result == macheps_func)")
end


println("------------ Exercise 2 ------------")
for T in [Float16, Float32, Float64]
    kahan_macheps(T)
end