module resultPrinter

export print_results

"""
Helper function to display the results of iterative methods.

Arguments:
    result      - Tuple (r, v, it, err) returned by the iterative method
    header      - String containing the header name to be displayed

Keyword Arguments (Optional):
    a, b        - Interval start/end points (for Bisection method)
    x0          - Initial guess (for Newton's and Secant methods)
    x1          - Second initial guess (for Secant method)
"""
function print_results(result::Tuple{Float64, Float64, Int, Int}, header::String; 
                           a=nothing, b=nothing, x0=nothing, x1=nothing)
    r, v, it, err = result
    
    println("\n$header")
    
    # Displaying input parameters based on the method type
    if a !== nothing && b !== nothing
        println("Initial interval [a, b]:  [$a, $b]")
    elseif x0 !== nothing && x1 !== nothing
        println("Initial values x0, x1:  $x0, $x1")
    elseif x0 !== nothing
        println("Initial value x0:  $x0")
    end
    
    # Display results
    println("Root (r):         $r")
    println("f(r) value (v):   $v")
    println("Iterations (it):  $it")
    println("Error code (err): $err")
end

end