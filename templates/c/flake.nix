{
  description = "C development project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = {nixpkgs, ...}: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    mkPkgs = system:
      import nixpkgs {
        inherit system;
      };

    mkDevShells = system: let
      pkgs = mkPkgs system;

      cTools = with pkgs; [
        gcc
        gdb
        gnumake
        cmake
        ninja
        pkg-config
        clang
        clang-tools
        lld
        mold
        valgrind
      ];

      mkShell = name: packages:
        pkgs.mkShell {
          inherit packages;

          shellHook = ''
            export PROJECT_NAME="${name}"

            echo "Loaded ${name} development shell for ${system}."
          '';
        };
    in {
      default = mkShell "c" cTools;
      c = mkShell "c" cTools;
    };
  in {
    devShells = forAllSystems mkDevShells;

    formatter = forAllSystems (system: let
      pkgs = mkPkgs system;
    in
      pkgs.writeShellApplication {
        name = "project-fmt";
        runtimeInputs = [pkgs.alejandra];

        text = ''
          if [ "$#" -eq 0 ]; then
            exec alejandra .
          fi

          exec alejandra "$@"
        '';
      });

    checks = forAllSystems (system: let
      pkgs = mkPkgs system;
    in {
      formatting =
        pkgs.runCommand "check-formatting" {
          nativeBuildInputs = [pkgs.alejandra];
        } ''
          alejandra --check ${./.}
          touch $out
        '';
    });
  };
}
