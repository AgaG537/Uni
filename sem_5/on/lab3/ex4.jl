# Agnieszka Głuszkiewicz


include("IterativeMethods.jl")
include("resultPrinter.jl")
using .IterativeMethods
using .resultPrinter

# input parameters
const DELTA = 0.5e-5 
const EPSILON = 0.5e-5
const MAX_IT = 20       # maximum iterations for iterative methods

# function definition
f(x) = sin(x) - ((1.0 / 4.0) * x^2)

# function derivative definition
df(x) = cos(x) - x / 2.0


println("------------ Exercise 4 ------------")
println("f(x) = sin(x) - (x/2)^2")
println("Delta = $(DELTA), Epsilon = $(EPSILON), Max_it = $(MAX_IT)")

# 1. Bisection Method
a_bisection = 1.5
b_bisection = 2.0
res = mbisekcji(f, a_bisection, b_bisection, DELTA, EPSILON)
print_results(res, "1. BISECTION METHOD:"; a=a_bisection, b=b_bisection)

# 2. Newton's Method
x0_newton = 1.5
res = mstycznych(f, df, x0_newton, DELTA, EPSILON, MAX_IT)
print_results(res, "2. NEWTON'S METHOD:"; x0=x0_newton)

# 3. Secant Method
x0_secant = 1.0
x1_secant = 2.0
res = msiecznych(f, x0_secant, x1_secant, DELTA, EPSILON, MAX_IT)
print_results(res, "3. SECANT METHOD:"; x0=x0_secant, x1=x1_secant)