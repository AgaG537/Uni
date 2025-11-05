# Agnieszka Głuszkiewicz

using JuMP
using GLPK
using CSV
using DataFrames

# Loads data from CSV files
function load_data(products_path::String, machines_path::String, times_path::String)
    products_df = CSV.read(products_path, DataFrame)
    machines_df = CSV.read(machines_path, DataFrame)
    times_df = CSV.read(times_path, DataFrame)

    products = products_df.Product
    machines = machines_df.Machine

    price = Dict(row.Product => row.Price for row in eachrow(products_df))
    material_cost = Dict(row.Product => row.MaterialCost for row in eachrow(products_df))
    demand = Dict(row.Product => row.MaxDemand for row in eachrow(products_df))

    hourly_cost = Dict(row.Machine => row.HourlyCost for row in eachrow(machines_df))
    hours_available = Dict(row.Machine => row.HoursAvailable for row in eachrow(machines_df))

    time_per_kg = Dict{String, Dict{String, Float64}}()
    for m in machines
        time_per_kg[m] = Dict{String, Float64}()
    end
    for row in eachrow(times_df)
        time_per_kg[row.Machine][row.Product] = row.MinutesPerKg
    end

    return products, machines, price, material_cost, demand, hourly_cost, hours_available, time_per_kg
end


# Creates the linear programming model
function build_model(products, machines, price, material_cost, demand, hourly_cost, hours_available, time_per_kg)
    model = Model(GLPK.Optimizer)

    # ---------- Decision variables ----------
    
    # x[p] : production quantity of product p [kg]
    @variable(model, 0 <= x[p in products] <= demand[p], base_name="Production_Quantity")

    # ---------- Objectives ----------
    
    # Total revenue: sum(price * quantity)
    @expression(model, TotalRevenue, 
        sum(price[p] * x[p] for p in products))
    
    # Total material cost: sum(materialcost * quantity)
    @expression(model, TotalMaterialCost, 
        sum(material_cost[p] * x[p] for p in products))
    
    # Machine operating cost: (total_time_minutes / 60) * hourly_cost
    @expression(model, MachineOperatingCost[m in machines],
        sum(time_per_kg[m][p] * x[p] for p in products) / 60 * hourly_cost[m])
        
    # Objective function: maximize profit = revenue - material cost - machine cost
    @objective(model, Max, TotalRevenue - TotalMaterialCost - sum(MachineOperatingCost[m] for m in machines))

    # ---------- Constraints ----------
    
    # MachineCapacity: total processing time on machine m [minutes]
    # must be less than or equal to total available minutes.
    @constraint(model, MachineCapacity[m in machines], 
        sum(time_per_kg[m][p] * x[p] for p in products) <= hours_available[m] * 60)

    return model, x
end


# Solves the model and calculates detailed results
function solve_model(model, x, products, machines, price, material_cost, hourly_cost, hours_available, time_per_kg)
    optimize!(model)

    status = termination_status(model)
    objective = objective_value(model)
    production = Dict(p => value(x[p]) for p in products)

    # Breakdown calculation
    revenue = sum(price[p] * production[p] for p in products)
    mat_cost = sum(material_cost[p] * production[p] for p in products)
    
    # Total time used on each machine (minutes)
    mach_time = Dict(m => sum(time_per_kg[m][p] * production[p] for p in products) for m in machines)
    
    # Total cost of machine usage
    mach_costs = Dict(m => (mach_time[m] / 60) * hourly_cost[m] for m in machines)

    return Dict(
        "status" => status,
        "objective" => objective,
        "production" => production,
        "revenue" => revenue,
        "material_cost" => mat_cost,
        "machine_time" => mach_time,
        "machine_costs" => mach_costs,
        "total_machine_cost" => sum(values(mach_costs)),
        "profit" => revenue - mat_cost - sum(values(mach_costs))
    )
end


# Prints the final solution details
function print_results(results)
    println("===== OPTIMAL SOLUTION =====")
    println("Status: ", results["status"])
    println("\nProduction quantities (kg):")
    for (p, q) in results["production"]
        println("  ", p, ": ", round(q, digits=2))
    end
    println("\nRevenue: \$", round(results["revenue"], digits=2))
    println("Material cost: \$", round(results["material_cost"], digits=2))
    println("\nMachine usage and costs:")
    for (m, t) in results["machine_time"]
        println("  ", m, ": ", round(t, digits=2), " minutes used, cost \$", round(results["machine_costs"][m], digits=2))
    end
    println("\nTotal machine cost: \$", round(results["total_machine_cost"], digits=2))
    println("TOTAL PROFIT: \$", round(results["profit"], digits=2))
end


# Main execution flow
function main()
    products, machines, price, material_cost, demand, hourly_cost, hours_available, time_per_kg =
        load_data("products.csv", "machines.csv", "times.csv")

    model, x = build_model(products, machines, price, material_cost, demand, hourly_cost, hours_available, time_per_kg)
    results = solve_model(model, x, products, machines, price, material_cost, hourly_cost, hours_available, time_per_kg)
    print_results(results)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end