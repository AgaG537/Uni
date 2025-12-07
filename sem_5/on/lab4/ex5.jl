# Agnieszka Głuszkiewicz


include("InterpolationMethods.jl")
using .InterpolationMethods

# degrees of the polynomial to be tested
n_values = [5, 10, 15]


println("(a) Function: f(x) = e^x, interval: [0, 1]")

# function definition
f1(x) = exp(x)

# interval boundaries
a1 = 0.0
b1 = 1.0

for n in n_values
    println("Plotting for n = $n")
    rysujNnfx(f1, a1, b1, n; wezly=:rownoodlegle)
end


println("(b) Function: f(x) = x^2 * sin(x), interval: [-1, 1]")

# function definition
f2(x) = x^2 * sin(x)

# interval boundaries
a2 = -1.0
b2 = 1.0

for n in n_values
    println("Plotting for n = $n")
    rysujNnfx(f2, a2, b2, n; wezly=:rownoodlegle)
end