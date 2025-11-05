# Agnieszka Głuszkiewicz

using JuMP
using GLPK
using CSV
using DataFrames
using Printf
using MathOptInterface

# Loads data from CSV files
function load_data(periods_path::String="periods.csv", params_path::String="params.csv")
    periods_df = CSV.read(periods_path, DataFrame)
    params_df = CSV.read(params_path, DataFrame)

    periods = Vector{Int}(periods_df.Period)
    C_normal = Dict(row.Period => float(row.C_normal) for row in eachrow(periods_df))
    A_overtime = Dict(row.Period => float(row.A_overtime_cap) for row in eachrow(periods_df))
    O_overtime = Dict(row.Period => float(row.O_overtime_cost) for row in eachrow(periods_df))
    Demand = Dict(row.Period => float(row.Demand) for row in eachrow(periods_df))

    params = Dict(row.key => float(row.value) for row in eachrow(params_df))

    for req in ["normal_capacity","inventory_capacity","holding_cost","initial_inventory"]
        @assert haskey(params, req) "Missing parameter '$req' in params.csv"
    end

    return periods, C_normal, A_overtime, O_overtime, Demand, params
end

# Builds the model
function build_model(periods, C_normal, A_overtime, O_overtime, Demand, params)
    normal_cap = params["normal_capacity"]
    inv_cap = params["inventory_capacity"]
    holding_cost = params["holding_cost"]
    inv0 = params["initial_inventory"]

    model = Model(GLPK.Optimizer)

    # ---------- Decision variables ----------

    # n[p]: normal production quantity in period p
    @variable(model, n[p in periods] >= 0)
    # o[p]: overtime production quantity in period p
    @variable(model, o[p in periods] >= 0)
    # s[p]: end-of-period inventory level in period p
    @variable(model, s[p in periods] >= 0)

    # ---------- Constraints ----------

    # Normal production capacity
    @constraint(model, [p in periods], n[p] <= normal_cap)
    # Overtime availability
    @constraint(model, [p in periods], o[p] <= A_overtime[p])
    # Inventory capacity
    @constraint(model, [p in periods], s[p] <= inv_cap)

    first_period = Base.first(periods)
    # Balance for the first period: inventory_end = inventory_start + production - demand
    @constraint(model, s[first_period] == inv0 + n[first_period] + o[first_period] - Demand[first_period])
    # Balance for subsequent periods: inventory_cur = inventory_prev + production - demand
    for (prev, cur) in zip(periods[1:end-1], periods[2:end])
        @constraint(model, s[cur] == s[prev] + n[cur] + o[cur] - Demand[cur])
    end

    # ---------- Objectives ----------

    # minimize total cost (normal production + overtime cost + holding cost)
    @objective(model, Min, sum(C_normal[p] * n[p] + O_overtime[p] * o[p] + holding_cost * s[p] for p in periods))
    return model, n, o, s
end

# Solves the model and extracts results into a dictionary
function solve_and_extract(model, n, o, s, periods, C_normal, O_overtime, params)
    optimize!(model)
    status = termination_status(model)
    if status != MathOptInterface.OPTIMAL
        @warn "Solver did not return OPTIMAL status: $status"
    end

    sol = Dict()
    sol["status"] = status
    sol["normal_prod"] = Dict(p => value(n[p]) for p in periods)
    sol["overtime_prod"] = Dict(p => value(o[p]) for p in periods)
    sol["end_inventory"] = Dict(p => value(s[p]) for p in periods)

    normal_cost = sum(C_normal[p] * sol["normal_prod"][p] for p in periods)
    overtime_cost = sum(O_overtime[p] * sol["overtime_prod"][p] for p in periods)
    holding_cost = params["holding_cost"]
    holding_cost_total = sum(holding_cost * sol["end_inventory"][p] for p in periods)
    sol["costs"] = Dict(
        "normal_cost" => normal_cost,
        "overtime_cost" => overtime_cost,
        "holding_cost" => holding_cost_total,
        "total_cost" => normal_cost + overtime_cost + holding_cost_total
    )
    return sol
end

# Prints the final solution details
function print_solution(sol, periods, Demand)
    println("===== OPTIMAL PLAN =====")
    println("Solver status: ", sol["status"])
    println()
    println(rpad("Period",8), rpad("Normal",12), rpad("Overtime",12), rpad("EndInv",12), rpad("Demand",10))
    for p in periods
        n = sol["normal_prod"][p]
        o = sol["overtime_prod"][p]
        s = sol["end_inventory"][p]
        println(rpad(string(p),8), 
                rpad(@sprintf("%.2f",n),12), 
                rpad(@sprintf("%.2f",o),12),
                rpad(@sprintf("%.2f",s),12), 
                rpad(@sprintf("%.2f",Demand[p]),10))
    end
    println()
    costs = sol["costs"]
    println("Normal production cost: \$", round(costs["normal_cost"]; digits=2))
    println("Overtime production cost: \$", round(costs["overtime_cost"]; digits=2))
    println("Holding cost (total): \$", round(costs["holding_cost"]; digits=2))
    println("-> Minimal TOTAL cost: \$", round(costs["total_cost"]; digits=2))

end

# Main execution flow
function main()
    periods, C_normal, A_overtime, O_overtime, Demand, params = load_data("periods.csv", "params.csv")
    model, n, o, s = build_model(periods, C_normal, A_overtime, O_overtime, Demand, params)
    sol = solve_and_extract(model, n, o, s, periods, C_normal, O_overtime, params)
    print_solution(sol, periods, Demand)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end