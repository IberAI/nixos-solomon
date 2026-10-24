{
  config,
  lib,
  pkgs,
  ...
}: let
  statusConfig = "${config.xdg.configHome}/i3status-rust/config-top.toml";
in {
  wayland.windowManager.sway.config = {
    bars = [
      {
        position = "top";
        statusCommand = "${lib.getExe pkgs.i3status-rust} ${statusConfig}";
        trayOutput = "none";

        fonts = {
          names = [
            "FiraCode Nerd Font"
            "DejaVu Sans Mono"
            "monospace"
          ];
          size = 9.0;
        };

        colors = {
          background = "#1e1e2e";
          statusline = "#cdd6f4";
          separator = "#585b70";
        };
      }
    ];
  };

  programs.i3status-rust = {
    enable = true;
    package = pkgs.i3status-rust;

    bars = {
      top = {
        icons = "awesome6";
        theme = "gruvbox-dark";

        blocks = [
          {
            block = "cpu";
            interval = 5;
          }
          {
            block = "memory";
            interval = 10;
          }
          {
            block = "sound";
            driver = "pulseaudio";
          }
          {
            block = "net";
          }
          {
            block = "time";
            interval = 60;
            format = " $timestamp.datetime(f:'%a %H:%M') ";
          }
        ];
      };
    };
  };
}
