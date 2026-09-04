{
  config,
  lib,
  osConfig,
  pkgs,
  profile,
  ...
}: let
  mod = "Mod4";
  inherit (builtins) toString;

  terminal = lib.getExe pkgs.${profile.desktop.terminal};
  browser = lib.getExe pkgs.${profile.desktop.browser};
  launcher = "${lib.getExe pkgs.rofi} -show drun";
  statusConfig = "${config.xdg.configHome}/i3status-rust/config-top.toml";

  lockScreen = pkgs.writeShellApplication {
    name = "sway-lock-screen";
    runtimeInputs = [pkgs.swaylock];
    text = ''
      swaylock --color 1e1e2e --indicator --ring-color 89b4fa --key-hl-color a6e3a1
    '';
  };

  screenshotRegion = pkgs.writeShellApplication {
    name = "sway-screenshot-region";
    runtimeInputs = with pkgs; [
      grim
      slurp
      wl-clipboard
      libnotify
    ];
    text = ''
      set -euo pipefail

      dir="$HOME/Pictures/ScreenShots"
      mkdir -p "$dir"

      file="$dir/screenshot-$(date +%Y-%m-%d-%H%M%S).png"
      if ! selection="$(slurp)" || [ -z "$selection" ]; then
        exit 0
      fi

      grim -g "$selection" "$file"
      wl-copy --type image/png < "$file"
      notify-send "Screenshot saved" "$file"
    '';
  };

  mkWorkspaceBindings = num: let
    n = toString num;
  in {
    "${mod}+${n}" = "workspace number ${n}";
    "${mod}+Shift+${n}" = "move container to workspace number ${n}";
  };
in {
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
      modifier = mod;
      inherit terminal;
      menu = launcher;

      fonts = {
        names = [
          # pkgs.font-awesome is 7.x, whose families are "Font Awesome 7 *".
          # The old 6 name matched nothing and silently fell through.
          "Font Awesome 7 Free"
          "FiraCode Nerd Font"
          "DejaVu Sans Mono"
          "monospace"
        ];
        size = 10.0;
      };

      window = {
        border = 2;
        titlebar = false;
        hideEdgeBorders = "smart";
      };

      floating = {
        border = 2;
        titlebar = true;
        modifier = mod;

        criteria = [
          {app_id = "pavucontrol";}
          {app_id = "blueman-manager";}
          {app_id = "nm-connection-editor";}
          {title = "Picture-in-Picture";}
          {window_role = "dialog";}
          {window_type = "dialog";}
          {window_type = "menu";}
        ];
      };

      focus = {
        followMouse = false;
        wrapping = "yes";
        newWindow = "smart";
        mouseWarping = false;
      };

      # sway does not inherit services.xserver.xkb, and nixpkgs exports no
      # XKB_DEFAULT_* variables, so the layout has to be handed to the
      # compositor directly. Same profile source as console.keyMap.
      input."*" =
        {
          xkb_layout = profile.keyboard.layout;
          xkb_model = profile.keyboard.model;
        }
        // lib.optionalAttrs (profile.keyboard.variant != "") {
          xkb_variant = profile.keyboard.variant;
        }
        // lib.optionalAttrs (profile.keyboard.options != []) {
          xkb_options = lib.concatStringsSep "," profile.keyboard.options;
        };

      # Override Sway's packaged wallpaper with a plain declarative background.
      output."*".bg = "#1e1e2e solid_color";

      workspaceAutoBackAndForth = true;
      workspaceLayout = "default";

      gaps = {
        inner = 8;
        outer = 4;
        smartGaps = true;
        smartBorders = "on";
      };

      colors = {
        background = "#1e1e2e";

        focused = {
          border = "#89b4fa";
          childBorder = "#89b4fa";
          background = "#89b4fa";
          text = "#11111b";
          indicator = "#89b4fa";
        };

        focusedInactive = {
          border = "#45475a";
          childBorder = "#45475a";
          background = "#313244";
          text = "#cdd6f4";
          indicator = "#45475a";
        };

        unfocused = {
          border = "#313244";
          childBorder = "#313244";
          background = "#1e1e2e";
          text = "#a6adc8";
          indicator = "#313244";
        };

        urgent = {
          border = "#f38ba8";
          childBorder = "#f38ba8";
          background = "#f38ba8";
          text = "#11111b";
          indicator = "#f38ba8";
        };

        placeholder = {
          border = "#585b70";
          childBorder = "#585b70";
          background = "#1e1e2e";
          text = "#cdd6f4";
          indicator = "#585b70";
        };
      };

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

      startup = [
        {
          command = "${pkgs.swayidle}/bin/swayidle -w timeout 600 '${lib.getExe lockScreen}' before-sleep '${lib.getExe lockScreen}'";
          always = false;
        }
        # Mako is D-Bus activated and nm-applet is a systemd user service, so
        # neither should also be started here.
      ];

      keybindings = lib.mkForce (
        mkWorkspaceBindings 1
        // mkWorkspaceBindings 2
        // mkWorkspaceBindings 3
        // mkWorkspaceBindings 4
        // mkWorkspaceBindings 5
        // mkWorkspaceBindings 6
        // mkWorkspaceBindings 7
        // {
          "${mod}+t" = "exec ${terminal}";
          # Open Rofi's desktop-application launcher with Super/Windows + R.
          "${mod}+r" = "exec ${launcher}";
          "${mod}+f" = "exec ${browser}";
          "${mod}+o" = "exec ${lib.getExe pkgs.nwg-displays} --num_ws 7";

          "${mod}+q" = "kill";
          "${mod}+Shift+c" = "reload";
          "${mod}+Shift+r" = "reload";
          "${mod}+Shift+e" = "exec ${pkgs.sway}/bin/swaymsg exit";

          "${mod}+l" = "exec ${lib.getExe lockScreen}";
          "${mod}+p" = "exec ${lib.getExe screenshotRegion}";

          "${mod}+a" = "focus left";
          "${mod}+d" = "focus right";
          "${mod}+w" = "focus up";
          "${mod}+s" = "focus down";

          "${mod}+Shift+a" = "move left";
          "${mod}+Shift+d" = "move right";
          "${mod}+Shift+w" = "move up";
          "${mod}+Shift+s" = "move down";

          "${mod}+h" = "split h";
          "${mod}+v" = "split v";
          "${mod}+e" = "layout toggle split";
          "${mod}+Shift+f" = "fullscreen toggle";

          "${mod}+space" = "focus mode_toggle";
          "${mod}+Shift+space" = "floating toggle";

          "${mod}+minus" = "scratchpad show";
          "${mod}+Shift+minus" = "move scratchpad";

          "${mod}+BackSpace" = "mode resize";

          "XF86AudioMute" = "exec ${lib.getExe pkgs.pamixer} -t";
          "XF86AudioLowerVolume" = "exec ${lib.getExe pkgs.pamixer} -d 5";
          "XF86AudioRaiseVolume" = "exec ${lib.getExe pkgs.pamixer} -i 5";
          "F10" = "exec ${lib.getExe pkgs.pamixer} -t";
          "F11" = "exec ${lib.getExe pkgs.pamixer} -d 5";
          "F12" = "exec ${lib.getExe pkgs.pamixer} -i 5";
          "XF86AudioMicMute" = "exec ${lib.getExe pkgs.pamixer} --default-source -t";

          "XF86AudioPlay" = "exec ${lib.getExe pkgs.playerctl} play-pause";
          "XF86AudioPause" = "exec ${lib.getExe pkgs.playerctl} play-pause";
          "XF86AudioNext" = "exec ${lib.getExe pkgs.playerctl} next";
          "XF86AudioPrev" = "exec ${lib.getExe pkgs.playerctl} previous";

          "XF86MonBrightnessUp" = "exec ${lib.getExe pkgs.brightnessctl} set +5%";
          "XF86MonBrightnessDown" = "exec ${lib.getExe pkgs.brightnessctl} set 5%-";
        }
      );

      modes = {
        resize = {
          "a" = "resize shrink width 10 px or 10 ppt";
          "d" = "resize grow width 10 px or 10 ppt";
          "w" = "resize shrink height 10 px or 10 ppt";
          "s" = "resize grow height 10 px or 10 ppt";

          "Left" = "resize shrink width 10 px or 10 ppt";
          "Right" = "resize grow width 10 px or 10 ppt";
          "Up" = "resize shrink height 10 px or 10 ppt";
          "Down" = "resize grow height 10 px or 10 ppt";

          "Return" = "mode default";
          "Escape" = "mode default";
        };
      };
    };

    extraConfig = ''
      for_window [title="Picture-in-Picture"] floating enable, sticky enable
      for_window [window_role="pop-up"] floating enable
      for_window [window_role="bubble"] floating enable
      for_window [window_role="task_dialog"] floating enable
      for_window [window_type="dialog"] floating enable
      for_window [window_type="menu"] floating enable

      # Written by nwg-displays. These remain ordinary writable files beside
      # the Home Manager-managed main config, so no manual editing is needed.
      include ~/.config/sway/outputs
      include ~/.config/sway/workspaces
    '';
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
      swayidle
      swaylock
      wl-clipboard
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
