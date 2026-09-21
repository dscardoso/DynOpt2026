# ---------------------------------------------------------------------------
# smoke_test.jl — checks that Julia, the five workshop packages, both solvers and
# plotting all work on your machine. Run it before Session 1, from the repository
# root, with:   julia --project=. setup/smoke_test.jl
# The last line should say SMOKE TEST PASSED. If it does not, send the output to
# the instructor.
# ---------------------------------------------------------------------------

using Printf
import Pkg
import InteractiveUtils

const REPO = dirname(@__DIR__)
const EXPECTED_JULIA = v"1.12.7"
const RUN_AS_SCRIPT = abspath(PROGRAM_FILE) == @__FILE__
const T_START = time()

# GR, the plotting backend, tries to open a window unless we tell it not to.
# There is no window in a Codespace, so we pick the file-only workstation type.
# Set it before Plots loads. If you already set it yourself, we leave it alone.
get!(ENV, "GKSwstype", "100")

# ── How each step is reported ────────────────────────────────────────────

function report_failure(n, label, err)
    println()
    println("SMOKE TEST FAILED")
    println("Step $n: $label")
    println()
    println("--- exception ---")
    showerror(stdout, err)
    println()
    println()
    println("--- versioninfo() ---")
    try
        InteractiveUtils.versioninfo()
    catch e2
        println("versioninfo() itself failed: ", e2)
    end
    println()
    println("--- Pkg.status() ---")
    try
        Pkg.status()
    catch e2
        println("Pkg.status() itself failed: ", e2)
    end
    println()
    println("Copy everything above into an email to the instructor.")
    flush(stdout)
    RUN_AS_SCRIPT && exit(1)
    error("SMOKE TEST FAILED at step $n: $label")
end

# Runs one step, times it, prints OK or the whole failure report.
function check(f::Function, n::Integer, label::AbstractString)
    t0 = time()
    local out
    try
        out = f()
    catch err
        report_failure(n, label, err)
    end
    @printf("[%d] OK    %-48s %6.2f s\n", n, label, time() - t0)
    out isa AbstractString && !isempty(out) && println("         ", out)
    return out
end

println("Dynamic optimization workshop, environment check")
println("Repository: ", REPO)
println()

# ── 1. Julia version ─────────────────────────────────────────────────────
# The Manifest was resolved on 1.12.7, so anything outside 1.12 is a problem.
check(1, "Julia version") do
    if !(VERSION.major == 1 && VERSION.minor == 12)
        error("this workshop needs Julia $EXPECTED_JULIA, and you are running $VERSION. " *
              "Install 1.12.7 or open the Codespace, which already has it.")
    end
    VERSION == EXPECTED_JULIA ||
        @warn "Running Julia $VERSION. The workshop was built and verified on $EXPECTED_JULIA."
    return "julia $VERSION (expected $EXPECTED_JULIA)"
end

# ── 2. The project environment ───────────────────────────────────────────
# Works whether you started Julia with --project=. or not. In the Codespace the
# packages are already there, so instantiate has nothing to do and returns at once.
check(2, "project environment") do
    Pkg.activate(REPO; io = devnull)
    Pkg.instantiate()
    return nothing
end

# ── 3. Loading the packages ──────────────────────────────────────────────
check(3, "loading JuMP, Ipopt, Optim, Plots, LaTeXStrings") do
    for pkg in (:JuMP, :Ipopt, :Optim, :Plots, :LaTeXStrings)
        @eval Main using $pkg
    end
    return nothing
end

# Printed out here rather than inside the step above, because the packages only
# become visible to already running code once that step has finished.
println("         JuMP ", pkgversion(JuMP), ", Ipopt ", pkgversion(Ipopt),
        ", Optim ", pkgversion(Optim), ", Plots ", pkgversion(Plots),
        ", LaTeXStrings ", pkgversion(LaTeXStrings))

# ── 4. The Session 1 reservoir, solved two ways ──────────────────────────
# One reservoir with 4 units of water, one season. Release x for irrigation and
# leave 4 - x for recreation. Calibration from Miranda and Fackler, Chapter 7.
# Optim and Ipopt should both land on x* = 3.7214057.
const X_STAR = 3.72140566
const W_STAR = 46.0562

check(4, "static reservoir: Optim and Ipopt agree") do
    α_1, β_1, α_2, β_2, s_bar = 14.0, 0.8, 10.0, 0.4, 4.0
    W(x) = α_1 * x^β_1 + α_2 * (s_bar - x)^β_2

    result  = Optim.optimize(x -> -W(x), 0.0, s_bar)
    x_optim = Optim.minimizer(result)

    model = JuMP.Model(Ipopt.Optimizer)
    JuMP.set_silent(model)
    JuMP.set_attribute(model, "sb", "yes")   # skip Ipopt's license banner
    JuMP.@variable(model, 0 <= x <= s_bar, start = s_bar / 2)
    JuMP.@objective(model, Max, α_1 * x^β_1 + α_2 * (s_bar - x)^β_2)
    JuMP.optimize!(model)
    JuMP.is_solved_and_feasible(model) ||
        error("Ipopt did not solve the static problem: $(JuMP.termination_status(model))")
    x_jump = JuMP.value(x)

    # Loose tolerances on purpose. We are checking that the solvers work, not
    # grading them to the last digit.
    isapprox(x_optim, x_jump; atol = 1e-5) ||
        error("Optim gave $x_optim and Ipopt gave $x_jump, which do not agree")
    isapprox(x_jump, X_STAR; atol = 1e-4) ||
        error("Ipopt gave x = $x_jump, and the known optimum is $X_STAR")
    isapprox(W(x_jump), W_STAR; atol = 1e-3) ||
        error("objective came out as $(W(x_jump)), and the known value is $W_STAR")

    return @sprintf("x* = %.6f (Optim), %.6f (Ipopt), W* = %.4f", x_optim, x_jump, W(x_jump))
end

# ── 5. Plotting to a file ────────────────────────────────────────────────
# This is the slow one on a cold machine because Julia compiles the plotting
# code the first time you use it. We throw the figure away.
check(5, "saving a plot to a PNG") do
    α_1, β_1, α_2, β_2, s_bar = 14.0, 0.8, 10.0, 0.4, 4.0
    W(x) = α_1 * x^β_1 + α_2 * (s_bar - x)^β_2
    x_grid = 0.01:0.01:3.99
    plt = Plots.plot(x_grid, W.(x_grid);
                     xlabel = "x, released for irrigation",
                     ylabel = LaTeXStrings.L"F(x) + U(4 - x)",
                     label = false)
    png_path = tempname() * ".png"
    Plots.savefig(plt, png_path)
    isfile(png_path) || error("savefig did not write $png_path")
    n_bytes = filesize(png_path)
    n_bytes > 0 || error("savefig wrote an empty file at $png_path")
    rm(png_path; force = true)
    return @sprintf("wrote and removed a %d byte PNG", n_bytes)
end

# ── 6. A model the size of Session 3 ─────────────────────────────────────
# The same reservoir over 200 years, written out as one optimization problem.
# This is the shape of Session 3 and it checks that Ipopt handles a few hundred
# variables and constraints without trouble.
check(6, "a 200-year model in Ipopt") do
    α_1, β_1, α_2, β_2 = 14.0, 0.8, 10.0, 0.4
    δ, M, k_rain = 0.9, 30.0, 2.0
    T, s_1 = 200, 4.0

    model = JuMP.Model(Ipopt.Optimizer)
    JuMP.set_silent(model)
    JuMP.set_attribute(model, "sb", "yes")   # skip Ipopt's license banner
    JuMP.@variable(model, x[1:T] >= 0, start = 2.0)          # releases
    JuMP.@variable(model, z[1:T] >= 0, start = 2.0)          # water left in place
    JuMP.@variable(model, 0 <= s[1:T+1] <= M, start = 8.0)   # stocks
    JuMP.@constraint(model, initial, s[1] == s_1)
    JuMP.@constraint(model, split[t = 1:T], z[t] == s[t] - x[t])
    JuMP.@constraint(model, transition[t = 1:T], s[t+1] == z[t] + k_rain)
    JuMP.@objective(model, Max,
                    sum(δ^(t - 1) * (α_1 * x[t]^β_1 + α_2 * z[t]^β_2) for t in 1:T))
    JuMP.optimize!(model)
    JuMP.is_solved_and_feasible(model) ||
        error("Ipopt did not solve the 200-year model: $(JuMP.termination_status(model))")

    n_var = JuMP.num_variables(model)
    n_con = sum(JuMP.num_constraints(model, F, S)
                for (F, S) in JuMP.list_of_constraint_types(model))
    # The stock climbs from 4 towards the steady state near 12.5 and stays there.
    s_mid = JuMP.value(s[100])
    isapprox(s_mid, 12.5; atol = 0.2) ||
        error("the stock at year 100 came out as $s_mid, and it should be close to 12.5")

    return @sprintf("%d variables, %d constraints, objective %.4f",
                    n_var, n_con, JuMP.objective_value(model))
end

# The last line is exactly SMOKE TEST PASSED, because that is the line
# setup/README.md tells students to look for. The total time goes above it.
println()
@printf("All six checks passed in %.1f s. You are ready for the workshop.\n", time() - T_START)
println("SMOKE TEST PASSED")
