# Project

General C development flake for Nix 26.05.

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

- `nix develop` or `nix develop .#c`: GCC, Clang, GDB, CMake, Ninja,
  pkg-config, LLD, Mold, and Valgrind.

Both shell names are available on `x86_64-linux` and `aarch64-linux`.
This standalone template has no CUDA dependencies or GPU environment setup.
For CUDA development on native x86_64 NixOS, use the general development
template's `cuda` shell instead.

## Edit First

Open `flake.nix` and edit the package categories near the top. Delete anything
you do not need.
