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
- `nix develop .#cuda`: CUDA toolkit and NVIDIA CUDA development tools (x86_64 Linux)
- `nix develop .#python`: Python, uv, ruff, pyright
- `nix develop .#full`: everything together; CUDA is included only on x86_64 Linux

Both `x86_64-linux` and `aarch64-linux` provide `default`, `js`, `c`,
`python`, and `full`. The `cuda` shell is exported only on `x86_64-linux`.
The ordinary shells do not add CUDA tools, CUDA environment variables, or
NVIDIA driver packages. The C/C++ compiler comes from each shell's stdenv.

## Edit First

Open `flake.nix` and edit the package categories near the top. Delete anything
you do not need.

## CUDA on NixOS

The `cuda` and x86_64 `full` shells use the CUDA package set's
`backendStdenv`, so the host C/C++ compiler is compatible with the pinned
CUDA toolkit. They retain the combined `cudatoolkit`, NVCC, CUDA runtime,
and nvprof tools. The combined toolkit supplies `CUDA_PATH` and `CUDA_HOME`
for projects that expect one toolkit directory. It is large; remove it and
choose individual CUDA components if your project does not need that layout.

Only these shells set `CUDA_PATH`, `CUDA_HOME`, and `LD_LIBRARY_PATH`.
The library path uses `/run/opengl-driver/lib` for the active NixOS NVIDIA
driver, followed by toolkit/runtime libraries and any existing library path.
It does not install or select a separate driver from Nixpkgs. Do not add CUDA
stub libraries to the runtime library path.

A compatible NVIDIA driver must already be enabled on the host. The shell
does not configure the kernel driver. These CUDA shells target native NixOS;
other Linux distributions need their own driver-library integration.
`allowUnfree = true` is already set for NVIDIA's toolkit license, but global
`cudaSupport` is not enabled for unrelated packages.

Check on the target NixOS machine:

```sh
nix develop .#cuda
nvcc --version
g++ --version
ls /run/opengl-driver/lib/libcuda.so*
```

Compile and run your project's CUDA workload to verify GPU execution. Merely
entering the shell or running `nvcc --version` does not exercise the GPU.

## Updating an existing project

Templates are copied when a project is created; changing the source template
does not update existing projects. Merge the new shell definitions into an
existing project's `flake.nix`, preserving its own dependencies and lock file.
