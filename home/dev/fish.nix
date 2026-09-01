# home/dev/fish.nix
{pkgs, ...}: {
  programs.fish = {
    enable = true;
    package = pkgs.fish;

    generateCompletions = true;
    preferAbbrs = true;

    ########################################
    # Shell environment
    ########################################

    interactiveShellInit = ''
      # Disable greeting
      set -g fish_greeting

      # Pager. The shell owns these two; it does not own EDITOR/VISUAL
      # (home/dev/nvchad.nix), TERMINAL (home/dev/kitty.nix) or BROWSER
      # (home/apps/browsers.nix), and it does not own XDG_CONFIG_HOME and
      # friends either, which xdg.enable already exports.
      set -gx PAGER less
      set -gx LESS "-R"

      # User paths
      fish_add_path -g \
        "$HOME/.local/bin" \
        "$HOME/bin" \
        "$HOME/.cargo/bin" \
        "$HOME/.npm-global/bin"

      # Fish colors
      set -g fish_color_command green
      set -g fish_color_error red
      set -g fish_color_param normal
      set -g fish_color_quote yellow
      set -g fish_color_autosuggestion brblack
      set -g fish_color_valid_path --underline
      set -g fish_color_cwd cyan

      # Useful behavior
      set -g fish_autosuggestion_enabled 1
    '';

    ########################################
    # Key bindings
    ########################################

    binds = {
      "\\cr" = {
        command = "history-pager";
        mode = "default";
      };
    };

    ########################################
    # Abbreviations
    ########################################
    # Abbreviations expand as you type, better than aliases
    # for short commands like g -> git or v -> nvim.

    shellAbbrs = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      ll = "ls -lah";
      la = "ls -A";
      l = "ls -lah";

      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph --decorate";

      v = "nvim";
      n = "nvim";

      hms = "home-manager switch";
      hmb = "home-manager build";

      ns = "sudo nixos-rebuild switch --flake .";
      nb = "sudo nixos-rebuild build --flake .";
      nt = "sudo nixos-rebuild test --flake .";
      ncg = "sudo nix-collect-garbage -d";
      ngc = "nix-collect-garbage -d";

      flakeup = "nix flake update";
      flakecheck = "nix flake check";
    };

    ########################################
    # Aliases
    ########################################
    # Aliases are better for commands you do not want expanded
    # into your command line visually.

    shellAliases = {
      cls = "clear";
      grep = "grep --color=auto";
      ip = "ip --color=auto";
      diff = "diff --color=auto";
      please = "sudo";
      nd = "nix develop --command fish";
      rebuild = "sudo nixos-rebuild switch --flake .";
      test-rebuild = "sudo nixos-rebuild test --flake .";
      update-flake = "nix flake update";

      open-browser = "mullvad-browser";
    };

    ########################################
    # Functions
    ########################################

    functions = {
      mkcd = {
        description = "Create a directory and cd into it";
        body = ''
          mkdir -p $argv[1]
          and cd $argv[1]
        '';
      };
      sx = {
        description = "Attach to SimpleX tmux session or start SimpleX over Tor";
        body = ''
          if tmux has-session -t simplex 2>/dev/null
            tmux attach -t simplex
          else
            tmux new-session -s simplex -- simplex-tor
          end
        '';
      };
      extract = {
        description = "Extract common archive formats";
        body = ''
          if test (count $argv) -lt 1
            echo "usage: extract <archive>"
            return 1
          end

          set file $argv[1]

          if not test -f "$file"
            echo "extract: '$file' is not a file"
            return 1
          end

          switch "$file"
            case "*.tar.bz2"
              tar xjf "$file"
            case "*.tar.gz"
              tar xzf "$file"
            case "*.tar.xz"
              tar xJf "$file"
            case "*.tar"
              tar xf "$file"
            case "*.tbz2"
              tar xjf "$file"
            case "*.tgz"
              tar xzf "$file"
            case "*.zip"
              unzip "$file"
            case "*.rar"
              unrar x "$file"
            case "*.7z"
              7z x "$file"
            case "*"
              echo "extract: unsupported archive type: $file"
              return 1
          end
        '';
      };

      nix-clean = {
        description = "Clean old Nix generations and run garbage collection";
        body = ''
          sudo nix-collect-garbage -d
          nix-collect-garbage -d
        '';
      };

      nix-generations = {
        description = "List NixOS and Home Manager generations";
        body = ''
          echo "NixOS generations:"
          sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

          echo
          echo "Home Manager generations:"
          home-manager generations
        '';
      };
    };
  };
}
