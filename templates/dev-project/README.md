# Project

General development flake for Nix 26.05.

## Start

```sh
nix develop
```

Optional direnv setup:

```sh
cp .envrc.example .envrc
direnv allow
```

## Shells

- `nix develop`: general tools
- `nix develop .#js`: Node.js, pnpm, Yarn, TypeScript tooling
- `nix develop .#c`: GCC, Clang tooling, CMake, GNU Make, GDB
- `nix develop .#cuda`: CUDA toolkit and NVIDIA CUDA development tools
- `nix develop .#python`: Python, uv, ruff, pyright
- `nix develop .#full`: everything together

## Edit First

Open `flake.nix` and edit the package categories near the top. Delete anything
you do not need.

CUDA packages require Linux, a compatible NVIDIA driver on the host, and
`allowUnfree = true`.
