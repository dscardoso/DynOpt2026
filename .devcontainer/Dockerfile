# ---------------------------------------------------------------------------
# Image for the DynOpt2026 workshop Codespace.
#
# What this does: install Julia 1.12.7 from the official tarball, instantiate and
# precompile the workshop environment for user `vscode`, then run the smoke test
# at build time so the first plot and the first solve are already compiled when a
# student opens the Codespace.
#
# Build and push (see .devcontainer/README.md for the full recipe):
#   docker build -t ghcr.io/dscardoso/dynopt2026:2026-09-21 -f .devcontainer/Dockerfile .
#
# Rebuilding this in a year: the three things to revisit are JULIA_VERSION and
# JULIA_SHA256 below, the base image tag, and Manifest.toml. Change them
# deliberately, one at a time, and re-run the check scripts in the
# development repository afterwards. Quarto is deliberately not installed:
# students run .jl files, they do not render slides.
# ---------------------------------------------------------------------------

# ubuntu-24.04 rather than a Julia image because Codespaces expects the `vscode`
# user, the sudo setup and the git/ssh plumbing this base image provides.
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

LABEL org.opencontainers.image.title="DynOpt2026" \
      org.opencontainers.image.description="Julia 1.12.7 with JuMP, Ipopt, Optim, Plots and LaTeXStrings, precompiled for the Dynamic Optimization workshop (DynOpt2026)." \
      org.opencontainers.image.source="https://github.com/dscardoso/DynOpt2026" \
      org.opencontainers.image.url="https://github.com/dscardoso/DynOpt2026" \
      org.opencontainers.image.authors="Diego S. Cardoso" \
      org.opencontainers.image.vendor="University of Illinois Urbana-Champaign"

# Pin the exact patch version. The Manifest was resolved on 1.12.7 and both Pkg
# and the Quarto Julia engine complain about a mismatch. The checksum is the line
# for julia-1.12.7-linux-x86_64.tar.gz in
# https://julialang-s3.julialang.org/bin/checksums/julia-1.12.7.sha256
ARG JULIA_VERSION=1.12.7
ARG JULIA_SHA256=4e7e9e776634d24835250de67cde39b0d4af15bc432eb20697e6be6c28ea69e8

# ── Julia itself, as root ────────────────────────────────────────────────
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl; \
    rm -rf /var/lib/apt/lists/*; \
    series="$(echo "${JULIA_VERSION}" | cut -d. -f1,2)"; \
    url="https://julialang-s3.julialang.org/bin/linux/x64/${series}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz"; \
    curl -fsSL -o /tmp/julia.tar.gz "${url}"; \
    echo "${JULIA_SHA256}  /tmp/julia.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/julia; \
    tar -xzf /tmp/julia.tar.gz -C /opt/julia --strip-components=1; \
    rm -f /tmp/julia.tar.gz; \
    ln -s /opt/julia/bin/julia /usr/local/bin/julia; \
    julia --version

# Docker does not pick HOME up from /etc/passwd when USER changes, and Julia puts
# its depot in $HOME/.julia. Without this the depot would land in /.julia.
# We leave JULIA_DEPOT_PATH alone on purpose: overriding it would hide the
# stdlib precompile caches that ship inside /opt/julia.
ENV HOME=/home/vscode

# Keep Pkg's automatic precompilation on, which is the default. Everything the
# workshop needs is already compiled in this image, so it only ever fires if
# someone changes the environment, and then it should fire.
ENV JULIA_PKG_PRECOMPILE_AUTO=1

# ── The workshop environment, as the user who will actually use it ───────
# Precompile caches live in the depot and are keyed by package, not by project
# path, so what we build here in /home/vscode/dynopt-build is reused when the
# student opens the repository at /workspaces/DynOpt2026.
USER vscode
WORKDIR /home/vscode/dynopt-build

COPY --chown=vscode:vscode Project.toml Manifest.toml ./
RUN julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'

# Running the smoke test here pays Julia's time-to-first-plot and
# time-to-first-solve at build time instead of in front of the class. It also
# means a broken image fails the build rather than the workshop.
COPY --chown=vscode:vscode setup/smoke_test.jl ./setup/smoke_test.jl
RUN julia --project=. setup/smoke_test.jl

# Drop the build scratch directory. The depot in /home/vscode/.julia is what matters.
RUN rm -rf /home/vscode/dynopt-build

WORKDIR /home/vscode
