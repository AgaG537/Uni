# Agnieszka Głuszkiewicz

include("IterativeMethods.jl")
include("resultPrinter.jl")

using .IterativeMethods
using .resultPrinter

# input parameters
const DELTA = 1e-5
const EPSILON = 1e-5
const MAX_IT = 100 

# function definitions
f1(x) = exp(1.0 - x) - 1.0
df1(x) = -exp(1.0 - x)

f2(x) = x * exp(-x)
df2(x) = exp(-x) * (1.0 - x)


println("------------ Exercise 6 ------------")
println("Delta = $DELTA, Epsilon = $EPSILON, Max_it = $MAX_IT")


println("\n\n1. FUNCTION f1:")

# 1. BISECTION
a1, b1 = 0.0, 2.0
res = mbisekcji(f1, a1, b1, DELTA, EPSILON)
print_results(res, "1.1.1. BISECTION METHOD:"; a=a1, b=b1)

a1, b1 = 0.0, 3.0
res = mbisekcji(f1, a1, b1, DELTA, EPSILON)
print_results(res, "1.1.2. BISECTION METHOD:"; a=a1, b=b1)

a1, b1 = -100.0, 100.0
res = mbisekcji(f1, a1, b1, DELTA, EPSILON)
print_results(res, "1.1.3. BISECTION METHOD:"; a=a1, b=b1)

a1, b1 = -1.0, 1500.0
res = mbisekcji(f1, a1, b1, DELTA, EPSILON)
print_results(res, "1.1.4. BISECTION METHOD:"; a=a1, b=b1)


# 2. NEWTON
x0_n = 0.5
res = mstycznych(f1, df1, x0_n, DELTA, EPSILON, MAX_IT)
print_results(res, "1.2.1. NEWTON'S METHOD:"; x0=x0_n)

x0_n = 1.5
res = mstycznych(f1, df1, x0_n, DELTA, EPSILON, MAX_IT)
print_results(res, "1.2.2. NEWTON'S METHOD:"; x0=x0_n)

x0_n = 10.0
res = mstycznych(f1, df1, x0_n, DELTA, EPSILON, MAX_IT)
print_results(res, "1.2.3. NEWTON'S METHOD:"; x0=x0_n)

x0_n = -10.0
res = mstycznych(f1, df1, x0_n, DELTA, EPSILON, MAX_IT)
print_results(res, "1.2.4. NEWTON'S METHOD:"; x0=x0_n)

x0_n = -100.0
res = mstycznych(f1, df1, x0_n, DELTA, EPSILON, MAX_IT)
print_results(res, "1.2.5. NEWTON'S METHOD:"; x0=x0_n)

x0_n = 100.0
res = mstycznych(f1, df1, x0_n, DELTA, EPSILON, MAX_IT)
print_results(res, "1.2.6. NEWTON'S METHOD:"; x0=x0_n)


# 3. SECANT
x0_s, x1_s = 0.5, 1.5
res = msiecznych(f1, x0_s, x1_s, DELTA, EPSILON, MAX_IT)
print_results(res, "1.3.1. SECANT METHOD:"; x0=x0_s, x1=x1_s)

x0_s, x1_s = -2.0, 2.0
res = msiecznych(f1, x0_s, x1_s, DELTA, EPSILON, MAX_IT)
print_results(res, "1.3.2. SECANT METHOD:"; x0=x0_s, x1=x1_s)

x0_s, x1_s = 0.0, 5.0
res = msiecznych(f1, x0_s, x1_s, DELTA, EPSILON, MAX_IT)
print_results(res, "1.3.3. SECANT METHOD:"; x0=x0_s, x1=x1_s)

x0_s, x1_s = -10.0, -7.0
res = msiecznych(f1, x0_s, x1_s, DELTA, EPSILON, MAX_IT)
print_results(res, "1.3.4. SECANT METHOD:"; x0=x0_s, x1=x1_s)

x0_s, x1_s = 8.0, 10.0
res = msiecznych(f1, x0_s, x1_s, DELTA, EPSILON, MAX_IT)
print_results(res, "1.3.5. SECANT METHOD:"; x0=x0_s, x1=x1_s)

x0_s, x1_s = -100.0, -90.0
res = msiecznych(f1, x0_s, x1_s, DELTA, EPSILON, MAX_IT)
print_results(res, "1.3.6. SECANT METHOD:"; x0=x0_s, x1=x1_s)



println("\n\n2. FUNCTION f2:")

# 1. BISECTION
a2, b2 = -1.0, 1.0
res = mbisekcji(f2, a2, b2, DELTA, EPSILON)
print_results(res, "2.1.1. BISECTION METHOD:"; a=a2, b=b2)

a2, b2 = -1.0, 2.0
res = mbisekcji(f2, a2, b2, DELTA, EPSILON)
print_results(res, "2.1.2. BISECTION METHOD:"; a=a2, b=b2)

a2, b2 = -10.0, 11.0
res = mbisekcji(f2, a2, b2, DELTA, EPSILON)
print_results(res, "2.1.3. BISECTION METHOD:"; a=a2, b=b2)

a2, b2 = -10.0, 110.0
res = mbisekcji(f2, a2, b2, DELTA, EPSILON)
print_results(res, "2.1.4. BISECTION METHOD:"; a=a2, b=b2)


# 2. NEWTON
x0_n2 = -0.5
res = mstycznych(f2, df2, x0_n2, DELTA, EPSILON, MAX_IT)
print_results(res, "2.2.1. NEWTON'S METHOD:"; x0=x0_n2)

x0_n2 = -10.0
res = mstycznych(f2, df2, x0_n2, DELTA, EPSILON, MAX_IT)
print_results(res, "2.2.2. NEWTON'S METHOD:"; x0=x0_n2)

x0_n2 = 0.5
res = mstycznych(f2, df2, x0_n2, DELTA, EPSILON, MAX_IT)
print_results(res, "2.2.3. NEWTON'S METHOD:"; x0=x0_n2)

x0_n2 = 1.0
res = mstycznych(f2, df2, x0_n2, DELTA, EPSILON, MAX_IT)
print_results(res, "2.2.4. NEWTON'S METHOD:"; x0=x0_n2)

x0_n2 = 1.5
res = mstycznych(f2, df2, x0_n2, DELTA, EPSILON, MAX_IT)
print_results(res, "2.2.5. NEWTON'S METHOD:"; x0=x0_n2)

x0_n2 = 50.0
res = mstycznych(f2, df2, x0_n2, DELTA, EPSILON, MAX_IT)
print_results(res, "2.2.6. NEWTON'S METHOD:"; x0=x0_n2)

x0_n2 = -100.0
res = mstycznych(f2, df2, x0_n2, DELTA, EPSILON, MAX_IT)
print_results(res, "2.2.7. NEWTON'S METHOD:"; x0=x0_n2)


# 3. SECANT
x0_s2, x1_s2 = -0.5, 0.5
res = msiecznych(f2, x0_s2, x1_s2, DELTA, EPSILON, MAX_IT)
print_results(res, "2.3.1. SECANT METHOD:"; x0=x0_s2, x1=x1_s2)

x0_s2, x1_s2 = -0.5, 1.0
res = msiecznych(f2, x0_s2, x1_s2, DELTA, EPSILON, MAX_IT)
print_results(res, "2.3.2. SECANT METHOD:"; x0=x0_s2, x1=x1_s2)

x0_s2, x1_s2 = -5.0, -10.0
res = msiecznych(f2, x0_s2, x1_s2, DELTA, EPSILON, MAX_IT)
print_results(res, "2.3.3. SECANT METHOD:"; x0=x0_s2, x1=x1_s2)

x0_s2, x1_s2 = -10.0, 11.0
res = msiecznych(f2, x0_s2, x1_s2, DELTA, EPSILON, MAX_IT)
print_results(res, "2.3.4. SECANT METHOD:"; x0=x0_s2, x1=x1_s2)

x0_s2, x1_s2 = 8.0, 9.0
res = msiecznych(f2, x0_s2, x1_s2, DELTA, EPSILON, MAX_IT)
print_results(res, "2.3.5. SECANT METHOD:"; x0=x0_s2, x1=x1_s2)

x0_s2, x1_s2 = -100.0, -90.0
res = msiecznych(f2, x0_s2, x1_s2, DELTA, EPSILON, MAX_IT)
print_results(res, "2.3.6. SECANT METHOD:"; x0=x0_s2, x1=x1_s2)

x0_s2, x1_s2 = 30.0, 40.0
res = msiecznych(f2, x0_s2, x1_s2, DELTA, EPSILON, MAX_IT)
print_results(res, "2.3.7. SECANT METHOD:"; x0=x0_s2, x1=x1_s2)