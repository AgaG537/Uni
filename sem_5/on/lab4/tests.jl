# Agnieszka Głuszkiewicz


using Test

include("InterpolationMethods.jl")
using .InterpolationMethods

@testset "InterpolationMethods Tests" begin

    # TEST 1: ilorazyRoznicowe, warNewton
        
    # A) f(x) = 2x + 1
    x_nodes = [0.0, 2.0]
    f_vals  = [1.0, 5.0]
    
    diffs = ilorazyRoznicowe(x_nodes, f_vals)
    
    @test diffs[1] == 1.0    # f[x0] = 1.0
    @test diffs[2] == 2.0    # f[x0, x1] = (5-1)/(2-0) = 2.0
    
    # f(1.0) should be 3.0
    val_at_1 = warNewton(x_nodes, diffs, 1.0)
    @test val_at_1 ≈ 3.0 atol=1e-10

    # B) f(x) = x^2
    x_nodes_2 = [-1.0, 0.0, 1.0]
    f_vals_2 = [1.0, 0.0, 1.0]
    
    diffs_2 = ilorazyRoznicowe(x_nodes_2, f_vals_2)
    
    # f(0.5) should be 0.25
    val_at_0_5 = warNewton(x_nodes_2, diffs_2, 0.5)
    @test val_at_0_5 ≈ 0.25 atol=1e-10


    # TEST 2: rysujNnfx
    
    # clean up previous tests if necessary
    if isdir("plots")
        rm("plots", recursive=true, force=true)
    end
    
    # function definition
    f(x) = x^3 - 2*x
    
    rysujNnfx(f, -2.0, 2.0, 5; wezly=:rownoodlegle)
    
    # verify if the file with plot was created
    expected_file = "plots/f_n5_rownoodlegle.png"
    
    @test isdir("plots")
    @test isfile(expected_file)
    
    # check if file is not empty
    if isfile(expected_file)
        @test filesize(expected_file) > 0
    end

end