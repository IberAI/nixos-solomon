{
  description = "General development project";

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

        config = {
          allowUnfree = true;
        };
      };

    mkDevShells = system: let
      pkgs = mkPkgs system;
      inherit (pkgs) lib;
      cudaSupported = system == "x86_64-linux";

      commonTools = with pkgs; [
        bashInteractive
        coreutils
        curl
        direnv
        fd
        git
        gnumake
        jq
        just
        nix-output-monitor
        ripgrep
        tree
        unzip
        wget
        zip
      ];

      nixTools = with pkgs; [
        alejandra
        deadnix
        nil
        nixd
        statix
      ];

      jsTools = with pkgs; [
        nodejs_24
        pnpm
        yarn-berry
        typescript
        typescript-language-server
        vscode-langservers-extracted
        prettier
        eslint
      ];

      cTools = with pkgs; [
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

      pythonTools = with pkgs; [
        python3
        uv
        ruff
        pyright
        python3Packages.black
        python3Packages.isort
        python3Packages.pytest
      ];

      cudaTools = with pkgs; [
        cudaPackages.cudatoolkit
        cudaPackages.cuda_nvcc
        cudaPackages.cuda_cudart
        cudaPackages.cuda_nvprof
      ];

      mkShell = {
        name,
        packages,
        cuda ? false,
      }:
        (pkgs.mkShell.override {
          stdenv =
            if cuda
            then pkgs.cudaPackages.backendStdenv
            else pkgs.stdenv;
        }) {
          inherit packages;
          shellHook =
            ''
              export PROJECT_NAME="${name}"
              export NIXPKGS_ALLOW_UNFREE=1

              if command -v node >/dev/null 2>&1; then
                export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
              fi
            ''
            + lib.optionalString cuda ''
              export CUDA_PATH="${pkgs.cudaPackages.cudatoolkit}"
              export CUDA_HOME="$CUDA_PATH"

              export LD_LIBRARY_PATH="/run/opengl-driver/lib:${lib.makeLibraryPath [
                pkgs.cudaPackages.cudatoolkit
                pkgs.cudaPackages.cuda_cudart
              ]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
            ''
            + ''
              echo "Loaded ${name} development shell for ${system}."
            '';
        };
    in
      {
        default = mkShell {
          name = "default";
          packages = commonTools ++ nixTools;
        };
        js = mkShell {
          name = "js";
          packages = commonTools ++ nixTools ++ jsTools;
        };
        c = mkShell {
          name = "c";
          packages = commonTools ++ nixTools ++ cTools;
        };
        python = mkShell {
          name = "python";
          packages = commonTools ++ nixTools ++ pythonTools;
        };
        full = mkShell {
          name = "full";
          packages = commonTools ++ nixTools ++ jsTools ++ cTools ++ pythonTools ++ lib.optionals cudaSupported cudaTools;
          cuda = cudaSupported;
        };
      }
      // lib.optionalAttrs cudaSupported {
        cuda = mkShell {
          name = "cuda";
          packages = commonTools ++ nixTools ++ cTools ++ cudaTools;
          cuda = true;
        };
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
