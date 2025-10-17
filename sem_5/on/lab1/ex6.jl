# Agnieszka Głuszkiewicz


# Function f
f(x::Float64) = sqrt(x^2 + 1.0) - 1.0

# Function g
g(x::Float64) = x^2 / (sqrt(x^2 + 1.0) + 1.0)

# Powers of 8 for arguments x
k_values = 1:15
x_values = [8.0^-k for k in k_values]

println("------------ Exercise 6 ------------")

for (k, x) in zip(k_values, x_values)
    fx = f(x)
    gx = g(x)
    
    # Calculating the ratio
    ratio = fx / gx

    println("$k.  f(8^(-$k)) = $fx \t g(8^(-$k)) = $gx \t r/g = $ratio")
end