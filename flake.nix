{
  description = "Solomon's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Keep this only if you actually use it in a module.
    # aporetic-font = {
    #   url = "github:Echinoidea/Aporetic-Nerd-Font";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nur,
    nix4nvchad,
    ...
  }: let
    profile = import ./lib/profile.nix;
    inherit (profile) system;

    pkgs = import nixpkgs {
      inherit system;

      config = {
        allowUnfree = true;
      };

      overlays = [
        nur.overlays.default
      ];
    };
  in {
    ########################################
    # Formatter
    ########################################
    #
    # Run:
    #   nix fmt

    formatter.${system} = pkgs.alejandra;

    ########################################
    # Dev shell
    ########################################
    #
    # Run:
    #   nix develop

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        alejandra
        deadnix
        statix
        just
        nix-tree
        nil
        nixd
      ];

      shellHook = ''
        export HOST_NAME=${profile.hostName}
        ${builtins.readFile ./scripts/dev-shell-hook.sh}
      '';
    };

    ########################################
    # Checks
    ########################################
    #
    # Run:
    #   nix flake check

    checks.${system} = {
      formatting =
        pkgs.runCommand "check-formatting" {
          nativeBuildInputs = [pkgs.alejandra];
        } ''
          alejandra --check ${self}
          touch $out
        '';

      deadnix =
        pkgs.runCommand "check-deadnix" {
          nativeBuildInputs = [pkgs.deadnix];
        } ''
          deadnix --fail ${self}
          touch $out
        '';

      statix =
        pkgs.runCommand "check-statix" {
          nativeBuildInputs = [pkgs.statix];
        } ''
          statix check ${self}
          touch $out
        '';
    };

    ########################################
    # NixOS host
    ########################################

    nixosConfigurations.${profile.hostName} = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs profile system;
      };

      modules = [
        {
          nixpkgs = {
            config.allowUnfree = true;
            overlays = [
              nur.overlays.default
            ];
          };
        }

        ./hosts/nixos
      ];
    };
  };
}
