host := "nixos"

fmt:
    nix fmt

check:
    nix flake check

lint:
    deadnix --fail .
    statix check .

build:
    sudo nixos-rebuild build --flake .#{{host}}

test:
    sudo nixos-rebuild test --flake .#{{host}}

switch:
    sudo nixos-rebuild switch --flake .#{{host}}
