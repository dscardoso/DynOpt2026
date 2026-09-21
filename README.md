# Dynamic Optimization with Open-Source Tools

Materials for the AAEA virtual workshop series, fall 2026. Three online sessions, 90 minutes each:

| Session | Date | Topic |
|---|---|---|
| 1 | Friday, September 26 | Julia, optimization, and a static reservoir |
| 2 | Friday, October 3 | The Bellman equation on a discrete state |
| 3 | Friday, October 10 | Continuous state: finite and infinite horizon |

All sessions run 2:00 to 3:30 PM Central Time. We solve dynamic programming problems in Julia with [JuMP](https://jump.dev), using a reservoir management problem as the running example.

## Start here

Before Session 1, follow the instructions in [`setup/README.md`](setup/README.md). They take about 15 minutes: create a free GitHub account, open a Codespace on this repository, and run the smoke test. There is nothing to install on your computer.

Do not fork this repository. Open the Codespace directly from the green **Code** button above.

## Materials

Sessions 2 and 3 will be added to this repository before each session. To get them, run `git pull` in your Codespace terminal (see `setup/README.md`, "Between sessions").

- **Session 1: Julia, optimization, and a static reservoir.** [[slides]](https://raw.githack.com/dscardoso/DynOpt2026/main/slides/session_1/DYNOPT_1_slides.html) [[notes]](https://raw.githack.com/dscardoso/DynOpt2026/main/slides/session_1/DYNOPT_1_notes.html)
  - `exercises/s1_warmup.jl`: run along with the first part of the session, nothing to fill in
  - `exercises/s1_inclass.jl`: the script we complete together
  - `exercises/s1_homework.jl`: take it further after the session
  - `solutions/`: complete versions of the in-class and homework scripts

_Tip: to save a slide deck as PDF, open it in the browser, press `e`, then print to PDF._

## Repository layout

```
setup/        pre-workshop instructions and the smoke test
exercises/    scripts with blanks to fill in during and after each session
solutions/    complete versions of the exercise scripts
slides/       slide sources (.qmd) and rendered HTML
.devcontainer Codespace configuration (Julia 1.12.7 and all packages preinstalled)
Project.toml  the Julia environment; Manifest.toml pins every package version
```

## Sources

- Miranda and Fackler, *Applied Computational Economics and Finance*, MIT Press, Chapter 7, for the reservoir model and its calibration
- [JuMP documentation](https://jump.dev/JuMP.jl/stable/), in particular the tutorials [Getting started with Julia](https://jump.dev/JuMP.jl/stable/tutorials/getting_started/getting_started_with_julia/) and [Getting started with JuMP](https://jump.dev/JuMP.jl/stable/tutorials/getting_started/getting_started_with_JuMP/)
- [Julia documentation](https://docs.julialang.org/)

## Contact

Diego S. Cardoso, University of Illinois Urbana-Champaign, dcardoso@illinois.edu

## License

Code (`exercises/`, `solutions/`, `setup/`, `.devcontainer/`, the Julia environment files) is released under the [MIT License](LICENSE). Slides and notes under `slides/` are released under [CC BY 4.0](LICENSE-CC-BY-4.0). Please credit Diego S. Cardoso and link to this repository when you reuse them.
