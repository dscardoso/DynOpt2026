# ---------------------------------------------------------------------------
# s1_inclass.jl — Session 1, Phases 2 and 3. Fill in the four TODO blanks.
#
# One reservoir holds s = 4 units of water. One single period. Release x
# for irrigation, leave 4 - x for recreation, and maximize the sum of benefits.
#
#     max_{0 <= x <= 4}  F(x) + U(4 - x)      F(x) = α_1 x^β_1,  U(z) = α_2 z^β_2
#     FOC:               F'(x) = U'(4 - x)
#
# Calibration from Miranda and Fackler, "Applied Computational Economics and
# Finance," Chapter 7. The book sets no initial water level; we adopt s = 4.
# ---------------------------------------------------------------------------
using JuMP, Ipopt, Optim, Plots

# ── Setup (given) ────────────────────────────────────────────────────────
α_1 = 14.0      # farmer benefit scale
β_1 = 0.8       # farmer benefit curvature
α_2 = 10.0      # recreation benefit scale
β_2 = 0.4       # recreation benefit curvature
s_bar = 4.0     # water in the reservoir this season

F(x)  = α_1 * x^β_1                   # farmers' benefit from x units of irrigation
U(z)  = α_2 * z^β_2                   # recreation benefit from z units left in place
dF(x) = α_1 * β_1 * x^(β_1 - 1)       # F'(x)
dU(z) = α_2 * β_2 * z^(β_2 - 1)       # U'(z)

# ═══ PHASE 2. One reservoir, one season: a static optimization problem════

# ── 2.1 Look at the objective (given) ────────────────────────────────────
W(x) = F(x) + U(s_bar - x)
x_grid = 0.01:0.01:3.99
plot(x_grid, W.(x_grid); xlabel = "x, released for irrigation",
     ylabel = "F(x) + U(4 - x)", label = false)
savefig("s1_objective.png")

# ── 2.2 Solve with Optim ─────────────────────────────────────────────────
# TODO 1. Optim minimizes. We want to maximize W on [0, s_bar], so hand it -W
#         as an anonymous function.
#         result = optimize(x -> ..., 0.0, s_bar)


x_optim = Optim.minimizer(result)
println("Optim:  x* = ", x_optim)

# ── 2.3 Solve with JuMP and Ipopt ────────────────────────────────────────
model = Model(Ipopt.Optimizer)
set_silent(model)
# TODO 2. Declare the release x, which must lie between 0 and s_bar, and give
#         Ipopt a starting point in the interior. Then write the objective
#         F(x) + U(s_bar - x) using α_1, β_1, α_2, β_2 directly.
#         @variable(model, ... <= x <= ..., start = s_bar / 2)
#         @objective(model, Max, ...)



print(model)
optimize!(model)
@assert is_solved_and_feasible(model)
x_jump = value(x)
println("JuMP:   x* = ", x_jump, "   (", termination_status(model), ")")

# ── 2.4 Verify ───────────────────────────────────────────────────────────
# TODO 3. At the optimum, F'(x) = U'(s_bar - x). Compute the difference at
#         x_jump. It should be zero up to the solver's tolerance.
#         residual = ...


println("FOC residual F'(x) - U'(4 - x) = ", residual)
println("Optim and JuMP agree: ", isapprox(x_optim, x_jump; atol = 1e-6))

# ── 2.5 Report (given) ───────────────────────────────────────────────────
W_opt = W(x_jump)
println("W*              = ", round(W_opt, digits = 4))
println("all irrigation  = ", round(F(s_bar), digits = 4))
println("all recreation  = ", round(U(s_bar), digits = 4))
println("share irrigated = ", round(100 * x_jump / s_bar, digits = 2), "%")

# ═══ PHASE 3. What the static model says and what it misses ══════════════

# ── 3.1 Wrap Phase 2 into a function (given) ─────────────────────────────
function solve_static(s)
    model = Model(Ipopt.Optimizer)
    set_silent(model)
    @variable(model, 0 <= x <= s, start = s / 2)
    @objective(model, Max, α_1 * x^β_1 + α_2 * (s - x)^β_2)
    optimize!(model)
    @assert is_solved_and_feasible(model)
    x_opt = value(x)
    return x_opt, s - x_opt, F(x_opt) + U(s - x_opt)
end
solve_static(4.0)

# ── 3.2 Loop over the reservoir level ────────────────────────────────────
function static_paths(s_grid)
    n = length(s_grid)
    x_path = zeros(n)
    z_path = zeros(n)
    W_path = zeros(n)
    for i in 1:n
        # TODO 4. Solve the static problem at s_grid[i] and store the three
        #         results in position i of the three vectors.


    end
    return x_path, z_path, W_path
end

s_grid = 1.0:0.5:30.0
x_path, z_path, W_path = static_paths(s_grid)

# ── 3.3 Plot (given) ─────────────────────────────────────────────────────
share = 100 .* x_path ./ s_grid
plot(s_grid, share; xlabel = "s, water in the reservoir",
     ylabel = "% released for irrigation", label = false, ylims = (80, 100))
savefig("s1_share.png")
println("share irrigated at s = 1: ", round(share[1], digits = 2),
        "%   at s = 30: ", round(share[end], digits = 2), "%")

# ── 3.4 The missing term (read, do not run) ──────────────────────────────
#   static FOC:    F'(x) = U'(s - x)
#   dynamic FOC:   F'(x_t) = U'(s_t - x_t) + δ λ_{t+1}
# At the long-run stock of the dynamic model, λ = 9.750, of which δ λ = 8.775
# is the value of leaving the water for next year. Ninety percent of what the
# water is worth is missing from today's problem. Session 2 puts it back.
