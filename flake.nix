{
  description = "Solomon's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
    nur,
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

    formatter.${system} = pkgs.writeShellApplication {
      name = "nixos-solomon-fmt";
      runtimeInputs = [pkgs.alejandra];
      text = ''
        if [ "$#" -eq 0 ]; then
          exec alejandra .
        fi

        exec alejandra "$@"
      '';
    };

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
        nix-output-monitor
        nix-index
        nvd
        nh
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
    # Flake templates
    ########################################
    #
    # Run from a new project directory:
    #   nix flake init -t /path/to/nixos-solomon#dev-project

    templates = {
      dev-project = {
        path = ./templates/dev-project;
        description = "General Nix 26.05 development flake with JS, C/C++, CUDA, Python, and tooling shells.";
        welcomeText = ''
          # General Development Flake

          Edit the top section of `flake.nix`, delete package categories you do
          not need, then run:

          ```sh
          nix develop
          nix flake check
          ```

          Named shells:

          - `nix develop .#default`
          - `nix develop .#js`
          - `nix develop .#c`
          - `nix develop .#cuda`
          - `nix develop .#python`
          - `nix develop .#full`
        '';
      };

      default = self.templates.dev-project;
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
