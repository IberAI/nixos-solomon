{
  lib,
  osConfig,
  pkgs,
  profile,
  ...
}: {
  imports = [
    ./sway/appearance.nix
    ./sway/windows.nix
    ./sway/workspaces.nix
    ./sway/input-output.nix
    ./sway/idle.nix
    ./sway/keybindings.nix
    ./sway/status-bar.nix
  ];

  wayland.systemd.target = "sway-session.target";

  wayland.windowManager.sway = {
    # Use the unwrapped package here to validate the generated config and to
    # reload it after Home Manager activation. The login compositor remains
    # the NixOS-managed wrapper and is launched with this config explicitly by
    # /etc/sway/solomon-session.
    enable = true;
    package = pkgs.sway;
    checkConfig = true;
    xwayland = true;
    systemd = {
      enable = true;
      # Home Manager requires this to match the NixOS D-Bus implementation.
      dbusImplementation = osConfig.services.dbus.implementation;
    };

    config = {
      modifier = "Mod4";
      terminal = lib.getExe pkgs.${profile.desktop.terminal};
      menu = "${lib.getExe pkgs.rofi} -show drun";
    };
  };

  home = {
    packages = with pkgs; [
      brightnessctl
      rofi
      grim
      i3status-rust
      libnotify
      nwg-displays
      pamixer
      playerctl
      slurp
      swaybg
      swaylock
      wl-clipboard
    ];
  };
}
