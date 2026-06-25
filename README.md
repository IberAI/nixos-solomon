# Solomon NixOS Hyper-V VM

This flake targets a NixOS 25.11 desktop VM on Hyper-V with Home Manager
25.11, X11, i3, and XRDP configured for Hyper-V Enhanced Session Mode.

## Layout

- `flake.nix` defines the `nixos` host output and developer tools.
- `hosts/nixos/` contains host-specific system entry points and hardware.
- `profiles/hyperv-vm.nix` chooses which reusable features are enabled.
- `modules/` contains reusable NixOS modules.
- `home/` contains Home Manager modules.
- `lib/profile.nix` contains non-secret shared defaults such as username,
  hostname, locale, keyboard layout, private include paths, and default desktop
  applications.
- `scripts/` contains shell scripts that are packaged or read by Nix modules.
- `templates/` contains examples for private files that must not be committed.
- `Justfile` provides shortcuts for manual format, lint, check, build, test,
  and switch commands.

## Private Identity Files

Git identity, email, signing keys, SSH keys, tokens, and other private values
must stay outside the committed flake.

The Home Manager Git module includes this private file at runtime:

```text
~/.config/git/local.inc
```

Start from:

```text
templates/git-local.inc.example
```

The SSH module includes this private file at runtime:

```text
~/.ssh/config.local
```

Start from:

```text
templates/ssh-config.local.example
```

For real secrets such as tokens, passwords, age keys, private certificates, or
API keys, use a dedicated encrypted secret system such as `sops-nix` or
`agenix`. Ignored local `.nix` files are not a reliable secret mechanism for a
pure Git flake.

## Keyboard

Keyboard configuration is centralized in `lib/profile.nix`.

- X11 layout: `tr`
- X11 model: `pc105`
- X11 variant: empty
- Console keymap: `trq`

Do not add extra `setxkbmap`, `home.keyboard`, or duplicate `services.xserver`
keyboard definitions unless you intentionally change the shared profile.

## Hyper-V Enhanced Session Mode

The profile enables:

- `virtualisation.hypervGuest.enable`
- `services.xrdp.enable`
- XRDP VSOCK transport with `port=vsock://-1:3389`
- Turkish RDP keyboard mapping asset from `assets/xrdp/km-0000041f.ini`

On Windows, Hyper-V Enhanced Session Mode must also be enabled in Hyper-V host
settings and used through VMConnect.

## Manual Commands

These are intentionally manual:

```sh
nix fmt
nix flake check
sudo nixos-rebuild test --flake .#nixos
sudo nixos-rebuild switch --flake .#nixos
```

The config is structured so checks/builds are easy to run, but they are not run
automatically by the repository.
