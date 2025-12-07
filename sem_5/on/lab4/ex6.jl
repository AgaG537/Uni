# Agnieszka Głuszkiewicz


include("InterpolationMethods.jl")
using .InterpolationMethods

# degrees of the polynomial to be tested
n_values = [5, 10, 15]


println("(a) Function: f(x) = abs(x), interval: [-1, 1]")

# function definition
f3(x) = abs(x)

# interval boundaries
a3 = -1.0
b3 = 1.0

for n in n_values
    println("Plotting for n = $n")
    rysujNnfx(f3, a3, b3, n; wezly=:rownoodlegle)
    rysujNnfx(f3, a3, b3, n; wezly=:czebyszew)
end


println("(b) Function: f(x) = 1 / (1 + x^2), interval: [-5, 5]")

# function definition
f4(x) = 1.0 / (1.0 + x^2)

# interval boundaries
a4 = -5.0
b4 = 5.0

for n in n_values
    println("Plotting for n = $n")
    rysujNnfx(f4, a4, b4, n; wezly=:rownoodlegle)
    rysujNnfx(f4, a4, b4, n; wezly=:czebyszew)
end