# Agnieszka Głuszkiewicz


# The number of elements to display
const N_SAMPLES = 5 

"""
Verifies and presents the first N_SAMPLES and last N_SAMPLES numbers for a given range
- interval_start: The starting value of the interval
- interval_end: The ending value of the interval
- delta: The theoretical step size for the interval
"""
function verify_range_spacing(interval_start::Float64, interval_end::Float64, delta::Float64)
    
    # Flag to track the overall consistency
    all_consistent = true

    println("\nVERIFYING RANGE: [$(interval_start), $(interval_end)]")
    
    println("\n----- FIRST $(N_SAMPLES) NUMBERS -----")
    
    # Variable holding the current machine value
    current_val = interval_start
    
    for k in 1:N_SAMPLES
        
        # Next machine value
        current_val = nextfloat(current_val)
        
        # Previous number in the sequence
        previous_val = prevfloat(current_val)
        
        # Checking consistency
        is_consistent = (previous_val + delta == current_val)
        
        println("$(k)) Value: $(current_val)")
        println("       Bitstring: $(bitstring(current_val))")
        
        if !is_consistent
            all_consistent = false
            println("       CONSISTENCY: FAILURE")
        end
    end
    
    println("----- LAST $(N_SAMPLES) NUMBERS (Descending Order) -----")

    # Variable holding the current machine value
    current_val = interval_end 
    
    for k in 1:N_SAMPLES
        
        # Previous number in the sequence
        previous_val = prevfloat(current_val)
        
        # Checking consistency
        is_consistent = (previous_val + delta == current_val)
        
        println("$(k)) Value: $(current_val)")
        println("       Bitstring: $(bitstring(current_val))")

        if !is_consistent
            all_consistent = false
            println("       CONSISTENCY: FAILURE")
        end
        
        current_val = previous_val 
    end

    println("\nOVERALL CONSISTENCY CHECK: $(all_consistent ? "SUCCESS" : "FAILURE")")
end



println("------------ Exercise 3 ------------")

# [1.0, 2.0]
verify_range_spacing(1.0, 2.0, 2.0^(-52))

# [0.5, 1.0]
verify_range_spacing(0.5, 1.0, 2.0^(-53))

# [2.0, 4.0]
verify_range_spacing(2.0, 4.0, 2.0^(-51))







# -------------------------------------------------------------------------------------------------
# Function to check every single machine number in the given interval - takes way too long time


"""
Verifies every machine number in the given interval
- interval_start: The starting value of the interval
- interval_end: The ending value of the interval
- delta: The theoretical step size for the interval
"""
function verify_full_range_spacing(interval_start::Float64, interval_end::Float64, delta::Float64)
    
    # The current machine value
    current_val = interval_start
    # Counter for errors found
    errors_found = 0
    
    println("----- Full Range Verification in [$(interval_start), $(interval_end)) -----")

    while current_val < interval_end
        next_val = nextfloat(current_val)
        
        # Calculated step
        step = next_val - current_val
        if step != delta
            errors_found += 1
        end
        
        current_val = next_val
    end

    if errors_found == 0
        println("OVERALL CONSISTENCY CHECK: SUCCESS")
    else
        println("OVERALL CONSISTENCY CHECK: FAILURE")
    end
end


# Execution time is way too long

# verify_full_range_spacing(1.0, 2.0, 2.0^-52)
# verify_full_range_spacing(0.5, 1.0, 2.0^-53)
# verify_full_range_spacing(2.0, 4.0, 2.0^-51)