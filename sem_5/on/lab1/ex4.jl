# Agnieszka Głuszkiewicz


"""
Function to experimentally find a number x in the interval (1, 2) 
for which x * (1/x) != 1.0
- start: starting point of the checked interval
"""
function find_violating_number(start::Float64)
    
    # The number to check
    x = nextfloat(start)

    while x < 2
        result = x * (1.0 / x)
        if result != 1.0
            return x
        end
        x = nextfloat(x)
    end
    
    return nothing
end



println("------------ Exercise 4 ------------")


x = find_violating_number(1.5)

if x !== nothing
    println("Found x: $(x)")
    println("x * (1/x) = $(x * (1.0 / x))")
else
    println("The violating value was not found in the search range up to 2")
end


smallest_x = find_violating_number(1.0)

if smallest_x !== nothing
    println("\nSmallest x: $(smallest_x)")
    println("x * (1/x) = $(smallest_x * (1.0 / smallest_x))")
else
    println("\nThe smallest violating value was not found in the search range up to 2")
end