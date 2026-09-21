# ---------------------------------------------------------------------------
# s1_homework.jl — Session 1, take it further. Fill in the four TODO blanks.
#
# Same static reservoir as in class:  max_{0 <= x <= s} F(x) + U(s - x).
# Three parts. (1) Who gets what at s = 4. (2) The same at s = 1 and s = 30.
# (3) Stretch: solve the first-order condition with a bisection you write.
# ---------------------------------------------------------------------------
using JuMP, Ipopt, Optim, Plots

# ── Setup (given) ────────────────────────────────────────────────────────
α_1 = 14.0
β_1 = 0.8
α_2 = 10.0
β_2 = 0.4

F(x)  = α_1 * x^β_1
U(z)  = α_2 * z^β_2
dF(x) = α_1 * β_1 * x^(β_1 - 1)
dU(z) = α_2 * β_2 * z^(β_2 - 1)

function solve_static(s)                 # from class
    model = Model(Ipopt.Optimizer)
    set_silent(model)
    @variable(model, 0 <= x <= s, start = s / 2)
    @objective(model, Max, α_1 * x^β_1 + α_2 * (s - x)^β_2)
    optimize!(model)
    @assert is_solved_and_feasible(model)
    x_opt = value(x)
    return x_opt, s - x_opt, F(x_opt) + U(s - x_opt)
end

# ═══ 1. Who gets what ════════════════════════════════════════════════════
# For a reservoir level s, walk x across (0, s) and record what each party
# receives. The optimum maximizes the sum. Both ends are corners.

function who_gets_what(s)
    x_grid = (0.01:0.01:0.99) .* s        # 99 points strictly inside (0, s)
    n = length(x_grid)
    farmers    = zeros(n)
    recreation = zeros(n)
    total      = zeros(n)
    for i in 1:n
        # TODO 1. Farmers receive F(x). Fill farmers[i].

        # TODO 2. Recreation receives U(s - x). Fill recreation[i].

        # TODO 3. The planner's objective is the sum. Fill total[i].

    end
    return x_grid, farmers, recreation, total
end

# Plot and report (given). Vertical lines at x = 0, the optimum, and x = s.
function report(s, filename)
    x_grid, farmers, recreation, total = who_gets_what(s)
    x_opt, z_opt, W_opt = solve_static(s)
    plot(x_grid, farmers;    label = "farmers F(x)", xlabel = "x, released for irrigation",
         ylabel = "benefit", title = "s = $s")
    plot!(x_grid, recreation; label = "recreation U(s - x)")
    plot!(x_grid, total;      label = "sum", linewidth = 2)
    vline!([0.0, x_opt, s]; linestyle = :dash, label = false)
    savefig(filename)
    gain = 100 * (W_opt / F(s) - 1)          # optimum against irrigating everything
    println("s = ", s, ":  x* = ", round(x_opt, digits = 4),
            "   W* = ", round(W_opt, digits = 4),
            "   all irrigation = ", round(F(s), digits = 4),
            "   all recreation = ", round(U(s), digits = 4),
            "   gain over all irrigation = ", round(gain, digits = 2), "%")
    return gain
end

gain_4 = report(4.0, "s1_homework_s4.png")

# ═══ 2. Scarcity changes the stakes ══════════════════════════════════════
gain_1  = report(1.0,  "s1_homework_s1.png")
gain_30 = report(30.0, "s1_homework_s30.png")
# When is the allocation worth arguing about?

# ═══ 3. Stretch: solve the FOC yourself ══════════════════════════════════
# F'(x) = U'(s - x) rearranges to  s - x = c * x^(1/3)  with the constant below,
# so the optimum solves  h(x) = x + c * x^(1/3) - s = 0.  h is increasing, h(0) < 0
# and h(s) > 0, so bisection on [0, s] cannot miss.
c = (α_2 * β_2 / (α_1 * β_1))^(1 / (1 - β_2))
h(x, s) = x + c * x^(1 / 3) - s           # the FOC as a root-finding problem

function bisect_static(s)
    lo = 0.0
    hi = s
    for iteration in 1:100
        mid = (lo + hi) / 2
        # TODO 4. If h(mid, s) < 0 the root is to the right: move lo up to mid.
        #         Otherwise move hi down to mid.


    end
    return (lo + hi) / 2
end

x_bisect = bisect_static(4.0)

# Check they match
x_optim  = Optim.minimizer(optimize(x -> -(F(x) + U(4.0 - x)), 0.0, 4.0))
x_jump   = solve_static(4.0)[1]
println("bisection x* = ", x_bisect)
println("Optim     x* = ", x_optim)
println("Ipopt     x* = ", x_jump)
println("FOC residual at the bisection root = ", dF(x_bisect) - dU(4.0 - x_bisect))
