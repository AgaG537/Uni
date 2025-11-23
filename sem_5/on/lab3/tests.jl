# Agnieszka Głuszkiewicz


using Test

include("IterativeMethods.jl")
using .IterativeMethods

# test parameters
const DELTA = 1e-7
const EPSILON = 1e-7
const MAX_IT = 50


# functions for testing

# Root: x = 3.0
f1(x) = x^3 - 27.0
df1(x) = 3.0 * x^2

# Root: x ≈ 0.739085
f2(x) = cos(x) - x
df2(x) = -sin(x) - 1.0

# At x=0 derivative is 0
f3(x) = x^2 - 1.0
df3(x) = 2.0 * x

# Root: x = 5.0
f4(x) = 2.0*x - 10.0


@testset "1. Bisection Method Tests" begin
    # f1: Interval [1.0, 4.0] contains root 3.0
    r, v, it, err = mbisekcji(f1, 1.0, 4.0, DELTA, EPSILON)
    @test err == 0
    @test isapprox(r, 3.0, atol=1e-5)
    @test abs(v) < 1e-5

    # f1: Interval [2.0, 4.0] - root 3.0 at the middle
    r, v, it, err = mbisekcji(f1, 2.0, 4.0, DELTA, EPSILON)
    @test err == 0
    @test it == 1
    @test r == 3.0
    @test v == 0.0

    # f1: Interval [4.0, 5.0] - function does not change sign
    r, v, it, err = mbisekcji(f1, 4.0, 5.0, DELTA, EPSILON)
    @test err == 1
    @test it == 0
end

@testset "2. Newton's Method Tests" begin
    # f2: Start at x0 = 1.0, expected root approx 0.739085
    r, v, it, err = mstycznych(f2, df2, 1.0, DELTA, EPSILON, MAX_IT)
    @test err == 0
    @test abs(v) < EPSILON
    @test isapprox(r, 0.739085, atol=1e-5)

    # f3: At x0 = 0.0, derivative is 0.0
    r, v, it, err = mstycznych(f3, df3, 0.0, DELTA, EPSILON, MAX_IT)
    @test err == 2

    # f2: Start at x0 = -100.0, not enough iterations to reach root at 1.0
    r, v, it, err = mstycznych(f2, df2, -100.0, DELTA, EPSILON, MAX_IT)
    @test err == 1
    @test it == MAX_IT
end

@testset "3. Secant Method Tests" begin
    # f1: Initial points 2.0 and 4.0, expected root 3.0
    r, v, it, err = msiecznych(f1, 2.0, 4.0, DELTA, EPSILON, MAX_IT)
    @test err == 0
    @test isapprox(r, 3.0, atol=1e-5)
    @test abs(v) < EPSILON

    # f4: Linear function check, root is 5.0
    r, v, it, err = msiecznych(f4, 0.0, 10.0, DELTA, EPSILON, MAX_IT)
    @test err == 0
    @test isapprox(r, 5.0, atol=DELTA)
end