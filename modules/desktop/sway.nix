{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.solomon.desktop.sway.enable {
    # This module owns the sway binary. Home Manager owns the sway config file
    # and sets package = null, so there is exactly one sway on PATH and one
    # place that wraps it.
    programs.sway = {
      enable = true;
      package = pkgs.sway;
      wrapperFeatures.gtk = true;
      xwayland.enable = true;
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          # Absolute path on purpose. A bare "sway" would be resolved against
          # whatever PATH greetd happens to hand the session, which is how you
          # end up launching a different wrapper than the one configured above.
          command = "${lib.getExe pkgs.tuigreet} --time --remember --cmd ${lib.getExe config.programs.sway.package}";
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
      loginShellInit = ''
        if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = /dev/tty1 ]; then
          exec sway
        fi
      '';

      # Session-wide display-server variables only. Anything that belongs to a
      # single program lives with that program: TERMINAL in home/dev/kitty.nix,
      # BROWSER and the MOZ_* pair in home/apps/browsers.nix, EDITOR/VISUAL in
      # home/dev/nvchad.nix.
      sessionVariables =
        {
          NIXOS_OZONE_WL = "1";
          QT_QPA_PLATFORM = "wayland;xcb";
          SDL_VIDEODRIVER = "wayland";
          CLUTTER_BACKEND = "wayland";
        }
        // lib.optionalAttrs config.solomon.hardware.nvidia.enable {
          # sway 1.12 no longer refuses to start on proprietary NVIDIA, but it
          # does raise a swaynag on every launch. Acknowledge it once here
          # instead of dismissing the nag at each login.
          SWAY_UNSUPPORTED_GPU = "true";
        };

      # The sway session tools are installed once, by Home Manager, in
      # home/desktop/sway.nix. programs.sway itself provides the sway binary
      # and programs.nm-applet provides the tray applet.
      systemPackages = [pkgs.pavucontrol];
    };
  };
}
