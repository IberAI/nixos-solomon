# NixOS 26.05 Flakes and Home Manager Guide

This document captures the flake-based workflow this repository uses for a fresh
native NixOS 26.05 and Home Manager 26.05 installation. It is written for this
repository's layout:

- `flake.nix` owns pinned inputs, formatter, dev shell, checks, and
  `nixosConfigurations`.
- `hosts/nixos/default.nix` is the host entry point.
- `modules/` contains reusable NixOS modules.
- `home.nix` and `home/` contain Home Manager modules.
- `lib/profile.nix` contains shared non-secret host and user facts.

## Current Version State

At the time this guide was written, the official stable NixOS manual is for
26.05 and the nix.dev reference lists Nix 2.34 as the Nix version in Nixpkgs
26.05. This branch tracks:

```nix
nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

home-manager = {
  url = "github:nix-community/home-manager/release-26.05";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

When refreshing the 26.05 lock file, update the inputs and test before switching:

```sh
nix flake update nixpkgs home-manager
nix flake check
sudo nixos-rebuild test --flake .#nixos
sudo nixos-rebuild switch --flake .#nixos
```

Because this branch is intended for a brand-new installation, both
`system.stateVersion` and `home.stateVersion` are set to `26.05`.

## Required Nix Settings

Flake commands use the newer `nix` command interface. Enable both experimental
features declaratively:

```nix
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
```

Good baseline settings for a personal NixOS workstation are:

```nix
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      auto-optimise-store = true;
      warn-dirty = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };

    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };
}
```

Only add extra substituters and trusted public keys for caches you actually use.
If an unprivileged user must pass extra substituters to the Nix daemon, that user
must be trusted or the substituter must be listed in `trusted-substituters`.
Avoid casually adding broad trusted users on multi-user machines.

## Flake Shape

A NixOS host flake should keep inputs explicit and outputs boring:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { nixpkgs, home-manager, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs;
      };

      modules = [
        home-manager.nixosModules.default
        ./hosts/nixos
      ];
    };
  };
}
```

Keep these rules:

- Pin release branches for stable systems: `nixos-26.05` with
  `home-manager/release-26.05`.
- Use `inputs.<name>.inputs.nixpkgs.follows = "nixpkgs"` when a flake should
  share the same pinned Nixpkgs revision.
- Pass only stable cross-module facts through `specialArgs`, such as `inputs`,
  `profile`, and `system`.
- Put real NixOS options in modules, not in `specialArgs`.
- Keep host-specific hardware and machine choices under `hosts/<host>/`.
- Keep reusable policy under `modules/`.

## Home Manager Integration

For a NixOS machine, prefer Home Manager as a NixOS module when the user
environment should rebuild with the system:

```nix
{
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    extraSpecialArgs = {
      inherit inputs profile;
    };

    users.${profile.username} = import ../home.nix;
  };
}
```

This repository already uses the important settings:

- `useGlobalPkgs = true` makes Home Manager use the system `pkgs`, which avoids
  an extra Nixpkgs evaluation and keeps overlays and `nixpkgs.config` consistent.
- `useUserPackages = true` installs user packages under `/etc/profiles`, which
  works better for whole-system builds and VM builds.
- `extraSpecialArgs` is the right place to pass `inputs` and `profile` into Home
  Manager modules.
- `programs.home-manager.enable = true` gives the user the `home-manager`
  command, even though activation is managed by `nixos-rebuild`.

Use Home Manager for user-space concerns:

- shell configuration
- Git, SSH, terminal, editor, and desktop application settings
- user systemd services
- XDG files under `$HOME`
- packages that are only needed by one user

Use NixOS modules for system concerns:

- users and groups
- boot loader, kernel, filesystems, networking, audio, portals
- system services and security policy
- virtualization, container engines, display manager, login/session plumbing
- packages required system-wide or by root-owned services

## State Versions

State versions are not release selectors. For an existing machine they should
usually stay at the version originally installed, even when inputs move forward.
This branch is different: it is for a new NixOS 26.05 installation, so both state
versions intentionally start at 26.05.

```nix
system.stateVersion = "26.05";
home.stateVersion = "26.05";
```

After the system is installed, do not bump these values casually. Change them
only as a deliberate migration after reading the NixOS and Home Manager release
notes.

## Daily Commands

From this repository:

```sh
nix develop
nix fmt
nix flake check
sudo nixos-rebuild build --flake .#nixos
sudo nixos-rebuild test --flake .#nixos
sudo nixos-rebuild switch --flake .#nixos
```

With the `Justfile`:

```sh
just fmt
just check
just build
just test
just switch
```

Use `test` before `switch` when changing desktop, networking, user services, or
Home Manager activation. Use `build` for a non-activating compile check.

## Updating Inputs

Use targeted updates for routine maintenance:

```sh
nix flake update nixpkgs
nix flake update home-manager
nix flake update nixpkgs home-manager
```

Use a full update when you intentionally want every input refreshed:

```sh
nix flake update
```

After any lock-file update:

```sh
nix flake check
sudo nixos-rebuild test --flake .#nixos
```

Commit `flake.nix` and `flake.lock` together when changing release branches.
Commit only `flake.lock` when only refreshing pinned revisions.

## Git and Dirty Trees

When a flake lives in a Git repository, Nix evaluates the tracked source tree.
Untracked files are invisible to the build. Before debugging confusing "file not
found" or "path does not exist" errors, check:

```sh
git status --short
```

If a new module is untracked, add it to Git before building:

```sh
git add path/to/new-module.nix
nix flake check
```

Dirty tracked files are usually accepted, but they reduce reproducibility. Treat
dirty rebuilds as local tests, not as a final deployable state.

## Tooling

This repository already includes a strong baseline in `devShells.default`:

- `alejandra`: opinionated formatter used by `nix fmt`
- `deadnix`: detects unused bindings and dead Nix code
- `statix`: lints Nix anti-patterns
- `nil`: Nix language server
- `nixd`: alternative Nix language server with strong option support
- `nix-tree`: explores closure size
- `just`: task runner for common commands

Recommended additional tools when needed:

- `nvd`: compare NixOS generations before switching or after upgrading.
- `nix-output-monitor`: clearer build progress for long rebuilds.
- `nh`: ergonomic wrapper around common NixOS/Home Manager rebuild workflows.
- `nix-index` or `nix-locate`: find which package provides a missing binary or
  file.
- `nix-inspect` or `nix repl`: inspect evaluated attributes and packages.

Do not add all of them by default. Add tools when they match a real workflow.

## Debugging Home Manager

If `nixos-rebuild switch` succeeds but user configuration did not activate,
inspect the Home Manager service:

```sh
systemctl status "home-manager-$USER.service"
```

If `home-manager.startAsUserService = true` is set, inspect the user service
instead:

```sh
systemctl --user status home-manager.service
```

Useful checks:

```sh
nix flake show
nix eval .#nixosConfigurations.nixos.config.system.build.toplevel
nix eval .#nixosConfigurations.nixos.config.home-manager.users.solomon.home.stateVersion
```

When a Home Manager option cannot see `profile` or `inputs`, check that the
NixOS module still passes them with:

```nix
home-manager.extraSpecialArgs = {
  inherit inputs profile;
};
```

## Best Practices for This Repository

- Keep one Nixpkgs pin for the system and Home Manager unless there is a clear
  reason to split them.
- Keep `allowUnfree` in the system-level `nixpkgs.config` when
  `useGlobalPkgs = true`.
- Prefer small modules grouped by ownership: `home/dev/git.nix`,
  `modules/networking.nix`, `modules/graphics/nvidia.nix`.
- Centralize repeated host/user constants in `lib/profile.nix`.
- Keep secrets outside the flake. Use `sops-nix` or `agenix` for real secrets.
- Add checks to `checks.${system}` when introducing tooling that should block a
  bad rebuild.
- Prefer `lib.mkIf config.solomon.<feature>.enable` for feature gates, as the
  existing modules do.
- Keep Home Manager activation tied to `nixos-rebuild` for this VM unless you
  intentionally want independent user-level deployments.

## Source References

- Nix flakes overview: https://nix.dev/concepts/flakes.html
- Nix flake update reference: https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake-update.html
- Nix configuration reference: https://nix.dev/manual/nix/latest/command-ref/conf-file.html
- NixOS manual, stable 26.05: https://nixos.org/manual/nixos/stable/
- Nixpkgs manual, stable: https://nixos.org/manual/nixpkgs/stable/
- Home Manager flakes: https://nix-community.github.io/home-manager/nix-flakes.html
- Home Manager NixOS module: https://nix-community.github.io/home-manager/installation/nixos.html
- NixOS option search: https://search.nixos.org/options
- i2pd upstream documentation: https://i2pd.readthedocs.io/
