{
  config,
  lib,
  pkgs,
  profile,
  ...
}: {
  config = lib.mkIf config.solomon.desktop.sway.enable {
    # Home Manager owns and validates ~/.config/sway/config. This system module
    # owns the compositor used by greetd and always passes that config
    # explicitly, so Sway can never silently fall back to /etc/sway/config.
    programs.sway = {
      enable = true;
      package = pkgs.sway;
      wrapperFeatures.gtk = true;
      xwayland.enable = true;
    };

    environment.etc."sway/solomon-session" = {
      mode = "0755";
      text = ''
        #!${pkgs.runtimeShell}
        set -eu

        config=${lib.escapeShellArg "${profile.homeDirectory}/.config/sway/config"}
        if [ ! -r "$config" ]; then
          echo "Sway configuration is missing: $config" >&2
          echo "Rebuild the NixOS flake so Home Manager activates it." >&2
          exit 1
        fi

        exec ${lib.getExe config.programs.sway.package} --unsupported-gpu --config "$config"
      '';
    };

    services.greetd = {
      enable = true;

      settings = {
        default_session = {
          command = "${lib.getExe pkgs.tuigreet} \
        --time \
        --remember \
        --remember-user-session \
        --asterisks \
        --cmd /etc/sway/solomon-session";

          user = "greeter";
        };
      };
    };

    # security.pam.services.swaylock is already declared by the upstream sway
    # module (wayland-session.nix), so it is not repeated here.

    fonts.packages = with pkgs; [
      adwaita-icon-theme
      font-awesome
      nerd-fonts.fira-code
    ];

    environment = {
      # Session-wide display-server variables only. Anything that belongs to a
      # single program lives with that program: TERMINAL in home/dev/kitty.nix,
      # BROWSER and the MOZ_* pair in home/apps/browsers.nix, EDITOR/VISUAL in
      # home/dev/nvchad.nix.
      sessionVariables = {
        SWAY_UNSUPPORTED_GPI = true;
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
      };

      systemPackages = [pkgs.pavucontrol];
    };
  };
}
