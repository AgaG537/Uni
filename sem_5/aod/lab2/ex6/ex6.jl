# Agnieszka Głuszkiewicz

using JuMP
using GLPK
using CSV
using DataFrames
using MathOptInterface

# Loads from CSV file
function load_data(file::String="squares.csv")
    df = CSV.read(file, DataFrame)
    m = maximum(df.Row)
    n = maximum(df.Col)
    # Containers: 1 if container present, 0 otherwise
    containers = Dict((row.Row,row.Col)=>row.Container for row in eachrow(df))
    return m, n, containers
end

# Returns list of grid cells covered by a camera at (i,j) with range k
function get_coverage(i,j,m,n,k)
    covered = []
    # Check vertical coverage
    for dx in -k:k
        x = i+dx
        if x >= 1 && x <= m
            push!(covered,(x,j))
        end
    end
    # Check horizontal coverage
    for dy in -k:k
        y = j+dy
        if y >= 1 && y <= n
            push!(covered,(i,y))
        end
    end
    return unique(covered)
end

# Builds the model
function build_model(m,n,containers,k)
    model = Model(GLPK.Optimizer)

    # Possible camera positions: grid cells without a container (value 0)
    camera_positions = [(i,j) for i in 1:m, j in 1:n if containers[(i,j)]==0]

    # Decision variables: 1 if camera placed at position p, 0 otherwise
    @variable(model, cam[camera_positions], Bin)

    # Constraints: each container must be covered by at least one camera
    for (ci,cj) in keys(containers)
        if containers[(ci,cj)]==1
            covering_cams = [(i,j) for (i,j) in camera_positions if (ci,cj) in get_coverage(i,j,m,n,k)]
            @constraint(model, sum(cam[(i,j)] for (i,j) in covering_cams) >= 1)
        end
    end

    # Objective: minimize the total number of cameras used
    @objective(model, Min, sum(cam[p] for p in camera_positions))

    return model, cam, camera_positions
end

# Solves the model and extracts solution details
function solve_model(model, cam, camera_positions)
    optimize!(model)
    status = termination_status(model)
    if status != MathOptInterface.OPTIMAL
        @warn "Solver did not return OPTIMAL status: $status"
    end
    # Positions where a camera was placed
    placed = [p for p in camera_positions if value(cam[p])>0.5]
    total_cams = length(placed)
    return Dict("status"=>status, "placed"=>placed, "total"=>total_cams)
end

# Prints the final solution
function print_solution(sol)
    println("Solver status: ", sol["status"])
    println("Total cameras used: ", sol["total"])
    println("Camera positions:")
    for (i,j) in sol["placed"]
        println("  (",i,",",j,")")
    end
end

# Main execution flow
function main()
    m,n,containers = load_data("squares.csv")
    
    println("Solution for k=1:")
    k = 1
    model, cam, camera_positions = build_model(m,n,containers,k)
    sol = solve_model(model, cam, camera_positions)
    print_solution(sol)
    
    println("\nSolution for k=2:")
    k = 2
    model, cam, camera_positions = build_model(m,n,containers,k)
    sol = solve_model(model, cam, camera_positions)
    print_solution(sol)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end