# Agnieszka Głuszkiewicz


include("IterativeMethods.jl")
include("resultPrinter.jl")
using .IterativeMethods
using .resultPrinter

# input parameters
const DELTA = 1e-4
const EPSILON = 1e-4

# function definition
f(x) = 3.0 * x - exp(x)

println("------------ Exercise 5 ------------")
println("f(x) = 3x - exp(x)")
println("Delta = $(DELTA), Epsilon = $(EPSILON)")

# ROOT 1: INTERVAL [0.5, 1.0]
a1 = 0.5
b1 = 1.0
res1 = mbisekcji(f, a1, b1, DELTA, EPSILON)
print_results(res1, "ROOT 1:", a=a1, b=b1)

# ROOT 2: INTERVAL [1.0, 2.0]
a2 = 1.0
b2 = 2.0
res2 = mbisekcji(f, a2, b2, DELTA, EPSILON)
print_results(res2, "ROOT 2:", a=a2, b=b2)