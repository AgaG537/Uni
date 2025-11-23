# Agnieszka Głuszkiewicz


# Module containing implementations of methods to solve equation f(x) = 0

module IterativeMethods

export mbisekcji, mstycznych, msiecznych


"""
Task 1: Bisection Method
Solves the equation f(x) = 0 in the interval [a, b]

Parameters:
    f       - The function f(x)
    a       - Start of the initial interval
    b       - End of the initial interval
    delta   - Tolerance for the interval width (|b-a|)
    epsilon - Tolerance for the function value (|f(x)|)

Returns:
    (r, v, it, err) - Tuple:
    r   - Approximation of the root
    v   - Value of f(r)
    it  - Number of iterations performed
    err - Error code:
          0 - No error
          1 - Function does not change sign in [a, b]
"""
function mbisekcji(f, a::Float64, b::Float64, delta::Float64, epsilon::Float64)
    fa = f(a)
    fb = f(b)
    e = b - a   # Interval width
    
    # Check initial condition (sign change)
    if sign(fa) == sign(fb)
        return (0.0, 0.0, 0, 1)
    end
    
    it = 0
    
    while true
        it += 1
        e = e / 2.0
        r = a + e    # Calculate midpoint
        v = f(r)
        
        # Stopping condition
        if abs(e) < delta || abs(v) < epsilon
            return (r, v, it, 0)
        end
        
        # Update the interval
        if sign(v) == sign(fa)
            a = r
            fa = v
        else
            b = r
            fb = v
        end
    end
end


"""
Task 2: Newton's Method (Method of Tangents)
Solves the equation f(x) = 0 iteratively

Parameters:
    f       - The function f(x)
    pf      - The derivative f'(x)
    x0      - Initial approximation
    delta   - Tolerance for the step size (|x_(i+1) - x_i|)
    epsilon - Tolerance for the function value (|f(x)|)
    maxit   - Maximum allowed number of iterations

Returns:
    (r, v, it, err) - Tuple:
    r   - Approximation of the root
    v   - Value of f(r)
    it  - Number of iterations performed
    err - Error code:
          0 - Method converged
          1 - Required accuracy not achieved within maxit
          2 - Derivative close to zero
"""
function mstycznych(f, pf, x0::Float64, delta::Float64, epsilon::Float64, maxit::Int)
    v = f(x0)
    
    # Check if x0 is already a root
    if abs(v) < epsilon
        return (x0, v, 0, 0)
    end
    
    for it = 1:maxit
        pv = pf(x0) # Derivative value
        
        # Check for near-zero derivative
        if abs(pv) < eps(Float64)
            return (x0, v, it, 2)
        end

        # Newton step
        x1 = x0 - v / pv
        v1 = f(x1)
        
        # Stopping conditions
        if (abs(x1 - x0) < delta) || (abs(v1) < epsilon)
            return (x1, v1, it, 0) 
        end
        
        x0 = x1
        v = v1
    end
    
    # If the loop finishes, convergence failed
    return (x0, v, maxit, 1)
end


"""
Task 3: Secant Method
Solves the equation f(x) = 0 iteratively

Parameters:
    f       - The function f(x)
    x0      - First initial approximation
    x1      - Second initial approximation
    delta   - Tolerance for the step size (|x_(i+1) - x_i|)
    epsilon - Tolerance for the function value (|f(x)|)
    maxit   - Maximum allowed number of iterations

Returns:
    (r, v, it, err) - Tuple:
    r   - Approximation of the root
    v   - Value of f(r)
    it  - Number of iterations performed
    err - Error code:
          0 - Method converged
          1 - Required accuracy not achieved within maxit
"""
function msiecznych(f, x0::Float64, x1::Float64, delta::Float64, epsilon::Float64, maxit::Int)
    v0 = f(x0)
    v1 = f(x1)
    
    for it = 1:maxit
        # Swap values if necessary
        if abs(v1) < abs(v0)
            x0, x1 = x1, x0
            v0, v1 = v1, v0
        end
        
        # Check for near-zero denominator
        if abs(v1 - v0) < eps(Float64)
            return (x1, v1, it, 1)
        end
        
        # Secant step calculation
        s = (x1 - x0) / (v1 - v0)
        x1, v1 = x0, v0
        x0 = x0 - v0 * s
        v0 = f(x0)
        
        # Stopping conditions
        if (abs(x1 - x0) < delta) || (abs(v0) < epsilon)
            return (x0, v0, it, 0) 
        end
    end
    
    # If the loop finishes, convergence failed
    return (x0, v0, maxit, 1)
end

end