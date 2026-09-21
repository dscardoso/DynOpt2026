# The workshop container

Notes for the instructor. Students never read this file.

`devcontainer.json` points at a prebuilt image on GitHub Container Registry rather
than building anything when a Codespace opens. The image already has Julia 1.12.7,
the five packages from `Manifest.toml`, and a precompiled depot, so a Codespace
comes up in the time it takes to pull the image and nothing compiles in front of
the class. A Codespaces prebuild is not needed on top of this.

## Rebuilding and pushing

From the repository root, not from `.devcontainer/`:

```bash
TAG=2026-09-21        # use the day you build it

docker build -t dynopt2026:$TAG -f .devcontainer/Dockerfile .

docker tag dynopt2026:$TAG ghcr.io/dscardoso/dynopt2026:$TAG
docker tag dynopt2026:$TAG ghcr.io/dscardoso/dynopt2026:latest

gh auth refresh -h github.com -s write:packages,read:packages   # once per machine
gh auth token | docker login ghcr.io -u dscardoso --password-stdin
# On a gh older than 2.23 there is no `gh auth token`; use the stored token instead:
#   grep -m1 oauth_token ~/.config/gh/hosts.yml | awk '{print $2}' | docker login ghcr.io -u dscardoso --password-stdin

docker push ghcr.io/dscardoso/dynopt2026:$TAG
docker push ghcr.io/dscardoso/dynopt2026:latest
```

Then edit the `"image"` line in `devcontainer.json` to the new date tag. The
`latest` tag is there as a convenience, but `devcontainer.json` should always name
an explicit date tag so a student's Codespace cannot pick up a new image in the
middle of the workshop.

Build takes about three minutes on a 22-core machine and the image is about 3.9 GB
uncompressed. Most of that is the devcontainer base image, Julia's own stdlib
precompile cache, and the Qt and GR artifacts that Plots pulls in. There is not
much to trim without losing the precompilation that is the point of the image.

## After the first push, on github.com

The package is private by default and a student's Codespace cannot pull it:

1. Go to https://github.com/users/dscardoso/packages/container/dynopt2026/settings
2. Danger Zone, "Change visibility", set to **Public**.
3. Under "Manage Actions access", link the `DynOpt2026` repository so the package
   shows on the repository page.

Check it from a machine that is not logged in:

```bash
docker logout ghcr.io
docker pull ghcr.io/dscardoso/dynopt2026:2026-09-21
```

## Checking a build before shipping it

```bash
docker run --rm -u vscode -v "$PWD:/workspaces/DynOpt2026" -w /workspaces/DynOpt2026 \
  dynopt2026:$TAG julia --project=. setup/smoke_test.jl
```

The last line must be `SMOKE TEST PASSED`, and the output must not mention
`Precompiling` or `Installed`. If it does, the image and `Manifest.toml` have
drifted apart and the image needs rebuilding. The Dockerfile also runs the smoke
test at build time, so a broken environment fails the build.

## Fallback if GHCR is unavailable

Replace the `"image"` line in `devcontainer.json` with:

```json
  "build": {
    "dockerfile": "Dockerfile",
    "context": ".."
  },
```

Everything else in the file stays as it is. The context has to be `..` because the
Dockerfile copies `Project.toml`, `Manifest.toml` and `setup/smoke_test.jl` from the
repository root. This path works, but each student then pays the full build, which
is several minutes, so it is a fallback and not the plan.

## Things that are the way they are on purpose

- **Julia is pinned to 1.12.7**, the exact patch. `Manifest.toml` was resolved on
  it, and Pkg and the Quarto engine both complain about a mismatch.
- **Quarto is not installed.** Students run `.jl` files; they do not render slides.
- **`GKSwstype=100`** is set in `containerEnv`. Saving a PNG works without it, but
  GR prints `GKS: cannot open display - headless operation mode active` on the
  first plot, which looks like a failure to a student who has never used Julia.
- **`HOME=/home/vscode` is set in the Dockerfile.** Docker does not read `HOME`
  from `/etc/passwd` when `USER` changes, and without it the Julia depot built at
  image-build time would land in `/.julia` and be invisible to the student.
- **`JULIA_DEPOT_PATH` is deliberately not set**, so Julia keeps the stdlib
  precompile caches that ship inside `/opt/julia` on its depot path.
- **`.dockerignore` at the repository root** keeps the rendered Quarto slides, about
  29 MB, out of the build context. The image only needs `Project.toml`,
  `Manifest.toml` and `setup/`.
