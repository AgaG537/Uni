# Agnieszka Głuszkiewicz


using Polynomials
using LinearAlgebra

# Coefficients of the Wilkinson polynomial P(x)
coefficients = reverse([
    1.0, -210.0, 20615.0,-1256850.0,
    53327946.0,-1672280820.0, 40171771630.0, -756111184500.0,          
    11310276995381.0, -135585182899530.0,
    1307535010540395.0,     -10142299865511450.0,
    63030812099294896.0,     -311333643161390640.0,
    1206647803780373360.0,     -3599979517947607200.0,
    8037811822645051776.0,      -12870931245150988800.0,
    13803759753640704000.0,      -8752948036761600000.0,
    2432902008176640000.0
])

# Function evaluates the exact Wilkinson polynomial p(x) in its product form
#   Inputs: x (The point of evaluation)
function p(x)
    result = 1
    # k: The exact root, ranging from 1 to 20
    for k in 1:20
        result *= (x - k)
    end
    return result
end


# Performs the experiment: calculates roots for the original and changed polynomials and reports results
function wilkinson_experiment()
    println("--- (A) Original polynomial ---")
    
    # polynomial in the standard form
    P = Polynomial(coefficients)
    # computed roots
    z_k = roots(P)
    sort!(z_k, by=real) 
    
    println("k | Computed zk | |P(zk)| | |p(zk)| | |zk - k|")

    for k in 1:20
        # the k-th computed root
        zk = z_k[k]
        # computed values
        val_P = abs(P(z_k[k]))
        val_p = abs(p(z_k[k]))
        err = abs(zk - k)
        
        println("$k | $zk | $val_P | $val_p | $err")
    end


    println("\n--- (B) Changed polynomial wielomian (change for c19) ---")
    
    # coefficients for the changed polynomial
    P_changed_coeffs = copy(coefficients)
    # changing the c19 coefficient by -2^-23
    P_changed_coeffs[20] = -210.0 - 2^(-23) 
    P_changed = Polynomial(P_changed_coeffs)
    
    # computed roots of the changed polynomial
    z_k_changed = roots(P_changed)
    sort!(z_k_changed, by=real) 

    println("k | Computed zk | |P(zk)| | |p(zk)| | |zk - k|")

    for k in 1:20
        # the k-th computed root
        zk = z_k_changed[k]
        # computed values
        val_P_changed = abs(P_changed(zk))
        val_p = abs(p(zk))
        err = abs(zk - k)
        
        println("$k | $(real(zk)) + i*$(imag(zk)) | $val_P_changed | $val_p | $err")
    end
end

println("------------ Exercise 4 ------------")

wilkinson_experiment()