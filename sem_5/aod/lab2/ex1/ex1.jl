# Agnieszka Głuszkiewicz

using JuMP
using GLPK
using CSV
using DataFrames

# Loads data from CSV files
function load_data(capacity_path::String, demand_path::String, cost_path::String)
    cap_df = CSV.read(capacity_path, DataFrame)
    dem_df = CSV.read(demand_path, DataFrame)
    cost_df = CSV.read(cost_path, DataFrame)

    firms = unique(cap_df.Firm)
    airports = unique(dem_df.Airport)

    capacity = Dict(row.Firm => row.Capacity for row in eachrow(cap_df))
    demand   = Dict(row.Airport => row.Demand for row in eachrow(dem_df))
    cost     = Dict((row.Firm, row.Airport) => row.Cost for row in eachrow(cost_df))

    return firms, airports, capacity, demand, cost
end


# Builds the linear programming model
function build_model(firms, airports, capacity, demand, cost)
    model = Model(GLPK.Optimizer)
    
    # Decision variable x[f, a]: the quantity of goods transported from firm f to airport a
    @variable(model, x[firms, airports] >= 0)

    # Objective: minimize total transport cost
    @objective(model, Min, sum(cost[(i, j)] * x[i, j] for i in firms, j in airports))

    # Supply constraints (each supplier can't exceed its capacity)
    @constraint(model, [i in firms], sum(x[i, j] for j in airports) <= capacity[i])

    # Demand constraints (each airport must receive its demand)
    @constraint(model, [j in airports], sum(x[i, j] for i in firms) == demand[j])

    return model, x
end


# Solves the LP and returns results as dictionaries
function solve_model(firms, airports, capacity, demand, cost)
    model, x = build_model(firms, airports, capacity, demand, cost)
    optimize!(model)

    results = Dict{String, Any}()
    results["status"] = termination_status(model)
    results["total_cost"] = objective_value(model)
    results["flows"] = Dict((i, j) => value(x[i, j]) for i in firms, j in airports)

    return results
end


# Displays solution details
function print_results(results, firms, airports, capacity, demand)
    flows = results["flows"]

    println("===== RESULTS =====")
    println("Solver status: ", results["status"])

    println("\nFuel delivery plan (gallons):")
    for j in airports
        println(" ", j, ":")
        for i in firms
            q = flows[(i, j)]
            if q > 0.5
                println("    ", i, " -> ", j, ": ", round(q))
            end
        end
    end
end


# Main execution flow
function main()
    capacity_path = "capacity.csv"
    demand_path   = "demand.csv"
    cost_path     = "cost.csv"

    firms, airports, capacity, demand, cost = load_data(capacity_path, demand_path, cost_path)
    results = solve_model(firms, airports, capacity, demand, cost)
    print_results(results, firms, airports, capacity, demand)
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
