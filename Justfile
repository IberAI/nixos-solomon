host := "nixos"

fmt:
    nix fmt

check:
    nix flake check

# Refresh every pinned input, then validate and build without activating it.
update:
    nix flake update
    nix flake check
    nix build .#nixosConfigurations.{{host}}.config.system.build.toplevel --no-link

# Activate only after the complete update pipeline succeeds.
update-switch: update
    sudo nixos-rebuild switch --flake .#{{host}}

lint:
    deadnix --fail .
    statix check .

build:
    sudo nixos-rebuild build --flake .#{{host}}

test:
    sudo nixos-rebuild test --flake .#{{host}}

switch:
    sudo nixos-rebuild switch --flake .#{{host}}
