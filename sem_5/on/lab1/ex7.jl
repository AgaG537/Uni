# Agnieszka Głuszkiewicz


# Function f
f(x::Float64) = sin(x) + cos(3.0 * x)

# Correct derivative
f_correct_derivative(x::Float64) = cos(x) - 3.0 * sin(3.0 * x)

# Approximating derivative using the given formula
f_approx_derivative(x0::Float64, h::Float64) = (f(x0 + h) - f(x0)) / h

# The evaluation point
x0 = 1.0

# Calculate the correct derivative value at x0
correct_derivative = f_correct_derivative(x0)

println("------------ Exercise 7 ------------")

for n in 0:54
    h = 2.0^-n
    
    # Calculate approximate derivative and error
    approx_derivative = f_approx_derivative(x0, h)
    absolute_error = abs(correct_derivative - approx_derivative)
    
    # Calculate 1.0 + h for analysis
    one_plus_h = 1.0 + h

    println("$n.  h = 2^(-$n) = $h \t approx_f'(x0) = $approx_derivative \t Error = $absolute_error \t 1.0 + h = $one_plus_h")
end