# ---------------------------------------------------------------------------
# s1_warmup.jl — Session 1, Phase 1. Run along with the slides. Nothing to fill in.
#
# In VS Code, put the cursor on a line and press Shift+Enter to run that line in
# the Julia REPL. Select several lines and press Shift+Enter to run them together.
# To run the whole file at once:   include("exercises/s1_warmup.jl")
# ---------------------------------------------------------------------------

# ── 1. Numbers ───────────────────────────────────────────────────────────
1 + 2
7 / 2                    # 3.5. Division always gives a Float64
2^10
typeof(1)
typeof(1.0)

# Floating point is not real arithmetic
0.1 * 3 == 0.3           # false
0.1 * 3 ≈ 0.3            # true. Type \approx then Tab to get ≈
isapprox(0.1 * 3, 0.3; atol = 1e-12)   # same, with an explicit tolerance

# ── 2. Vectors and matrices ──────────────────────────────────────────────
v = [1.0, 2.0, 3.0]
v[1]                     # Julia counts from 1
v[end]
length(v)
zeros(5)
A = [1.0 2.0; 3.0 4.0]   # spaces separate columns, ; separates rows
A[2, 1]
A * v[1:2]
A'                       # transpose
A[:, 1]                  # first column. Matrices are stored column by column, so loop down a column, not across a row

# ── 3. Functions ─────────────────────────────────────────────────────────
function benefit(x)
    return 14 * x^0.8
end
benefit(2.0)

benefit_short(x) = 14 * x^0.8        # one-line form. Same thing
benefit_short(2.0)

function benefit_kw(x; scale = 14.0, curvature = 0.8)   # keyword arguments with defaults
    return scale * x^curvature
end
benefit_kw(2.0)
benefit_kw(2.0; curvature = 0.5)

function split_water(s, share)       # returning two numbers
    x = share * s
    z = s - x
    return x, z
end
irrigation, recreation = split_water(4.0, 0.9)   # and unpacking them

# An anonymous function has no name. You will hand one to a solver in Phase 2.
negative_benefit = x -> -benefit(x)
negative_benefit(2.0)

# ── 4. Loops, if, and preallocate-and-fill ───────────────────────────────
for i in 1:3
    println("year ", i)
end

# Preallocate a vector, then fill it in a loop. This is the only data pattern
# the workshop uses.
function benefits_on_grid(n)
    results = zeros(n)
    for i in 1:n
        results[i] = benefit(i)
    end
    return results
end
benefits_on_grid(5)

function describe(s)
    if s < 5
        return "low"
    elseif s < 20
        return "medium"
    else
        return "high"
    end
end
describe(4.0)

# ── 5. Be careful with variable scope ────────────────────────────────────
# Run these lines one at a time with Shift+Enter and last_year becomes 3.
# Run the file with include() and last_year stays 0, after a warning that is
# easy to miss. Inside a file, a top-level loop cannot assign to a variable
# defined outside it: Julia quietly makes a new one that dies with the loop.
# (If the loop also reads the variable, as in total = total + i, the file
# version stops with an UndefVarError instead.)
last_year = 0
for i in 1:3
    last_year = i
end
println("last_year after the loop = ", last_year)

# How to fix it: put the loop inside a function
function sum_to(n)
    total = 0.0
    for i in 1:n
        total = total + i
    end
    return total
end
println("sum_to(3) = ", sum_to(3))

# ── 6. Broadcasting ──────────────────────────────────────────────────────
x_values = [1.0, 2.0, 3.0]
benefit.(x_values)       # the dot applies benefit to each element
# benefit(x_values)      # error: ^ is not defined for a Vector. The dot is not optional
x_values .+ 1.0          # element by element
# x_values + 1.0         # error: vector plus scalar is not defined
x_values .^ 2

# ── 7. Unicode names ─────────────────────────────────────────────────────
# Type \alpha then Tab to get α. Subscripts are written with an underscore.
α_1 = 14.0
β_1 = 0.8
F(x) = α_1 * x^β_1
F(2.0)

# ── 8. Plots ─────────────────────────────────────────────────────────────
using Plots
x_grid = 0.1:0.1:4.0
plot(x_grid, F.(x_grid); xlabel = "x", ylabel = "benefit", label = "farmers")
plot!(x_grid, 10 .* x_grid .^ 0.4; label = "recreation")
vline!([2.0]; linestyle = :dash, label = false)
savefig("s1_warmup.png")
