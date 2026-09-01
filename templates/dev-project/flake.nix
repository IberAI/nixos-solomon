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
          cudaSupport = system == "x86_64-linux";
        };
      };

    mkDevShells = system: let
      pkgs = mkPkgs system;
      inherit (pkgs) lib;

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

      pythonTools = with pkgs; [
        python3
        uv
        ruff
        pyright
        python3Packages.black
        python3Packages.isort
        python3Packages.pytest
      ];

      cudaTools = lib.optionals (system == "x86_64-linux") (with pkgs; [
        cudaPackages.cudatoolkit
        cudaPackages.cuda_nvcc
        cudaPackages.cuda_cudart
        cudaPackages.cuda_nvprof
      ]);

      mkShell = name: packages:
        pkgs.mkShell {
          inherit packages;

          shellHook = ''
            export PROJECT_NAME="${name}"
            export NIXPKGS_ALLOW_UNFREE=1

            if command -v node >/dev/null 2>&1; then
              export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
            fi

            if command -v nvcc >/dev/null 2>&1; then
              export CUDA_PATH="${pkgs.cudaPackages.cudatoolkit}"
              export CUDA_HOME="$CUDA_PATH"
              export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
              pkgs.cudaPackages.cudatoolkit
              pkgs.cudaPackages.cuda_cudart
            ]}:''${LD_LIBRARY_PATH:-}"
            fi

            echo "Loaded ${name} development shell for ${system}."
          '';
        };
    in {
      default = mkShell "default" (commonTools ++ nixTools);
      js = mkShell "js" (commonTools ++ nixTools ++ jsTools);
      c = mkShell "c" (commonTools ++ nixTools ++ cTools);
      python = mkShell "python" (commonTools ++ nixTools ++ pythonTools);
      cuda = mkShell "cuda" (commonTools ++ nixTools ++ cTools ++ cudaTools);
      full = mkShell "full" (commonTools ++ nixTools ++ jsTools ++ cTools ++ pythonTools ++ cudaTools);
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
