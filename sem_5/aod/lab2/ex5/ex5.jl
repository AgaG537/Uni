# Agnieszka Głuszkiewicz

using JuMP
using GLPK
using CSV
using DataFrames
using Printf
using MathOptInterface

# Loads data from CSV files
function load_data(districts_file::String="districts.csv",
                   shift_file::String="shift_requirements.csv",
                   district_file::String="district_requirements.csv")

    districts_df = CSV.read(districts_file, DataFrame)
    shift_req_df = CSV.read(shift_file, DataFrame)
    district_req_df = CSV.read(district_file, DataFrame)

    districts = Vector(districts_df.District)
    shifts = Vector(shift_req_df.Shift)

    min_shift = Dict((d,s) => districts_df[findfirst(districts_df.District .== d), Symbol("MinShift$s")] for d in districts, s in shifts)
    max_shift = Dict((d,s) => districts_df[findfirst(districts_df.District .== d), Symbol("MaxShift$s")] for d in districts, s in shifts)
    min_shift_total = Dict(s => shift_req_df.MinAvailable[s] for s in shifts)
    min_district_total = Dict(d => district_req_df.MinAvailable[findfirst(district_req_df.District .== d)] for d in districts)

    return districts, shifts, min_shift, max_shift, min_shift_total, min_district_total
end

# Builds the model
function build_model(districts, shifts, min_shift, max_shift, min_shift_total, min_district_total)
    model = Model(GLPK.Optimizer)

    # ---------- Decision variables ----------

    # x[d, s]: number of vehicles allocated to district d during shift s. Must be an integer
    @variable(model, x[d in districts, s in shifts] >= 0, Int)

    # ---------- Constraints ----------

    # Min/max constraints per district & shift
    for d in districts, s in shifts
        @constraint(model, x[d,s] >= min_shift[(d,s)])
        @constraint(model, x[d,s] <= max_shift[(d,s)])
    end

    # Min total per shift constraint
    for s in shifts
        @constraint(model, sum(x[d,s] for d in districts) >= min_shift_total[s])
    end

    # Min total per district constraint
    for d in districts
        @constraint(model, sum(x[d,s] for s in shifts) >= min_district_total[d])
    end

    # ---------- Objectives ----------

    # minimize total vehicles used
    @objective(model, Min, sum(x[d,s] for d in districts, s in shifts))

    return model, x
end

# Solves the model and extracts solution details
function solve_model(model, x, districts, shifts)
    optimize!(model)
    status = termination_status(model)
    if status != MathOptInterface.OPTIMAL
        @warn "Solver did not return OPTIMAL status: $status"
    end
    allocation = Dict((d,s)=>value(x[d,s]) for d in districts, s in shifts)
    total_vehicles = sum(allocation[(d,s)] for d in districts, s in shifts)
    return Dict("status"=>status, "allocation"=>allocation, "total_vehicles"=>total_vehicles)
end

# Prints the final results
function print_solution(sol, districts, shifts)
    println("Solver status: ", sol["status"])
    println("Allocation of vehicles per district and shift:")
    println(rpad("District",10), [rpad("Shift$s",8) for s in shifts]...)
    for d in districts
        println(rpad(d,10), [rpad(@sprintf("%.0f",sol["allocation"][(d,s)]),8) for s in shifts]...)
    end
    println("Total vehicles used: ", sol["total_vehicles"])
end

# Main execution flow
function main()
    districts, shifts, min_shift, max_shift, min_shift_total, min_district_total =
        load_data("districts.csv","shift_requirements.csv","district_requirements.csv")
    model, x = build_model(districts, shifts, min_shift, max_shift, min_shift_total, min_district_total)
    sol = solve_model(model, x, districts, shifts)
    print_solution(sol, districts, shifts)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end