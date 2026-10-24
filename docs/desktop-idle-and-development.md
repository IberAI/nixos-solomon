# Desktop Idle Locking and Development Shells

This describes the repository configuration. Changes take effect on the native
PC only after rebuilding and activating there. Updating templates affects new
projects, not existing project copies.

## Idle locking

`home/desktop/sway/idle.nix` uses Home Manager's `services.swayidle` module.
Home Manager manages `swayidle.service`, starts it with `sway-session.target`,
stops it with the session, and restarts it if the process exits. There is no
second `swayidle` command in the Sway startup configuration.

The policy is:

- Lock after 600 seconds of inactivity.
- Lock before system suspend.
- Lock on logind requests, including `loginctl lock-session`.
- Keep `Super+L` as the direct manual lock shortcut.
- Do not automatically suspend the PC or power down its monitors.

All paths use the themed wrapper in `home/desktop/sway/commands.nix`.
The wrapper uses `exec` and forwards arguments. The idle service passes
`--daemonize` and runs with `-w`: Swaylock returns after establishing the lock,
so swayidle does not block until the user unlocks. Password authentication is
provided by the NixOS Sway module's PAM configuration.

### Activate on the native PC

Ensure newly added modules are tracked so the Git flake includes them, then
validate and activate:

```sh
git add home/desktop/sway
nix flake check
sudo nixos-rebuild switch --flake .#nixos
```

Log out of Sway and log back in once after this migration. The old startup
process remains alive in an existing session even after its configuration
entry is removed; logging out removes it and gives the new session exactly one
systemd-managed idle process. This also applies the workspace assignments to
new workspaces.

Check the service inside the new Sway session:

```sh
systemctl --user status swayidle.service
journalctl --user -u swayidle.service -b
pgrep -a -x swayidle
```

Expect one swayidle process with `-w`, a 600-second timeout, and `--daemonize`
in its lock commands. Test `Super+L`, unlock with the account password, then
test `loginctl lock-session`. To trigger the idle action immediately:

```sh
systemctl --user kill --signal=SIGUSR1 swayidle.service
```

This deliberately locks the session. Unlock normally, then confirm the service
remains active. Test suspend/resume separately if you use suspend on this PC.

## Project environments

The root `nix develop` provides tools for maintaining this NixOS configuration.
It is separate from the flakes exported under `templates/`.

| Template | Architecture | Shells |
| --- | --- | --- |
| `dev-project` | x86_64 Linux | default, js, c, python, cuda, full |
| `dev-project` | ARM64 Linux | default, js, c, python, full |
| `c` | x86_64 and ARM64 Linux | default, c |

In `dev-project`, CUDA tools and hook references are included only when the
shell explicitly enables CUDA: `cuda` and the x86_64 `full` shell. Ordinary
shells do not enable global `cudaSupport` or import CUDA paths just because
`nvcc` happens to be visible in the parent environment. ARM64 `full` remains a
general-purpose environment with no CUDA setup.

CUDA shells use `cudaPackages.backendStdenv` for a compatible host compiler.
The combined toolkit remains available as `CUDA_PATH` and `CUDA_HOME` for
software expecting a unified toolkit directory. `LD_LIBRARY_PATH` uses the
active NixOS driver at `/run/opengl-driver/lib`, followed by toolkit/runtime
libraries and the existing path. No separate `stable` NVIDIA driver package
is injected into the project shell; the workstation retains its configured
`production` driver branch.

CUDA still requires a compatible, working NVIDIA driver on the native PC.
Evaluating a shell does not prove GPU execution. See the
[general template README](../templates/dev-project/README.md) for runtime
checks and how to update existing projects. The
[C template README](../templates/c/README.md) documents the CPU-only alternative.

## Upstream references

- [Home Manager 26.05 swayidle options and service](https://github.com/nix-community/home-manager/blob/release-26.05/modules/services/swayidle.nix)
- [Swayidle wait/daemonize guidance](https://github.com/swaywm/swayidle/blob/master/swayidle.1.scd)
- [Nixpkgs CUDA documentation](https://github.com/NixOS/nixpkgs/blob/nixos-26.05/doc/languages-frameworks/cuda.section.md)
