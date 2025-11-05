# Agnieszka Głuszkiewicz

using JuMP
using GLPK
using CSV
using DataFrames
using MathOptInterface

# Loads data from CSV file
function load_graph(csv_path::String="graph.csv")
    df = CSV.read(csv_path, DataFrame)
    nodes = unique(vcat(df.From, df.To))
    arcs = [(row.From,row.To) for row in eachrow(df)]
    cost = Dict((row.From,row.To) => row.Cost for row in eachrow(df))
    time = Dict((row.From,row.To) => row.Time for row in eachrow(df))
    return nodes, arcs, cost, time
end

# Builds the shortest path model
function build_model(nodes, arcs, cost, time, source, sink, T=nothing)
    model = Model(GLPK.Optimizer)

    # x[a]: binary decision variable, 1 if arc a is used, 0 otherwise
    @variable(model, x[a in arcs], Bin)

    # Objective: minimize total cost
    @objective(model, Min, sum(cost[a]*x[a] for a in arcs))

    # Flow conservation constraints
    for n in nodes
        if n == source
            # Flow out of source equals 1
            @constraint(model, sum(x[(i,j)] for (i,j) in arcs if i==n) - sum(x[(i,j)] for (i,j) in arcs if j==n) == 1)
        elseif n == sink
            # Flow into sink equals 1 (net flow equals -1)
            @constraint(model, sum(x[(i,j)] for (i,j) in arcs if i==n) - sum(x[(i,j)] for (i,j) in arcs if j==n) == -1)
        else
            # Flow conservation for intermediate nodes (flow in equals flow out)
            @constraint(model, sum(x[(i,j)] for (i,j) in arcs if i==n) - sum(x[(i,j)] for (i,j) in arcs if j==n) == 0)
        end
    end

    # Time constraint
    if T !== nothing
        @constraint(model, sum(time[a]*x[a] for a in arcs) <= T)
    end

    return model, x
end


# Solves the model and extracts solution details
function solve_model(model, x, arcs, cost)
    optimize!(model)
    status = termination_status(model)
    if status != MathOptInterface.OPTIMAL
        @warn "Solver did not return OPTIMAL status: $status"
    end
    # Selected arcs (where flow is 1)
    solution_arcs = [a for a in arcs if value(x[a]) > 0.5]
    # Total cost of the selected path
    total_cost = sum(cost[a] for a in solution_arcs)
    return Dict("status"=>status, "selected_arcs"=>solution_arcs, "total_cost"=>total_cost)
end


# Prints solution details
function print_solution(sol, title)
    println("")
    println("----" * title * "----")
    println("Total cost: ", sol["total_cost"])
    println("Solver status: ", sol["status"])
    println("Selected arcs:")
    for a in sol["selected_arcs"]
        println("  ", a)
    end
end

# Main execution flow
function main()
    nodes, arcs, cost, time = load_graph("graph.csv")
    source = 1
    sink = 10
    T = 15

    # Solves first graph with time constraint T=15
    model, x = build_model(nodes, arcs, cost, time, source, sink, T)
    sol = solve_model(model, x, arcs, cost)
    print_solution(sol, "graph from exercise")


    nodes, arcs, cost, time = load_graph("graph_custom.csv")
    source = 1
    sink = 10
    T = 6

    # Solves custom graph with time constraint T=6
    model2, x2 = build_model(nodes, arcs, cost, time, source, sink, T)
    sol2 = solve_model(model2, x2, arcs, cost)
    print_solution(sol2, "custom graph with time constraint")

    # Solves custom graph without time constraint
    model3, x3 = build_model(nodes, arcs, cost, time, source, sink)
    sol3 = solve_model(model3, x3, arcs, cost)
    print_solution(sol3, "custom graph without time constraint")

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end