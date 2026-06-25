{
  config,
  lib,
  pkgs,
  profile,
  ...
}: let
  mod = "Mod4"; # Super / Windows key
  inherit (builtins) toString;

  screenshotRegion = pkgs.writeShellApplication {
    name = "i3-screenshot-region";
    runtimeInputs = [
      pkgs.maim
      pkgs.slop
      pkgs.xclip
      pkgs.libnotify
    ];
    text = builtins.readFile ../../scripts/i3-screenshot-region.sh;
  };

  lockScreen = pkgs.writeShellApplication {
    name = "i3-lock-screen";
    runtimeInputs = [pkgs.i3lock];
    text = builtins.readFile ../../scripts/i3-lock-screen.sh;
  };

  mkWorkspaceBindings = num: let
    n = toString num;
  in {
    "${mod}+${n}" = "workspace number ${n}";
    "${mod}+Shift+${n}" = "move container to workspace number ${n}";
  };
in {
  xsession = {
    enable = true;

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3;

      config = {
        modifier = mod;

        terminal = "${pkgs.${profile.desktop.terminal}}/bin/${profile.desktop.terminal}";
        menu = "${pkgs.rofi}/bin/rofi -show drun";

        fonts = {
          names = [
            "Font Awesome 6 Free"
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
            {class = "Pavucontrol";}
            {class = "Blueman-manager";}
            {class = "Nm-connection-editor";}
            {class = "Arandr";}
            {class = "Lxappearance";}
            {title = "Picture-in-Picture";}
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

            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${config.xdg.configHome}/i3status-rust/config-top.toml";

            fonts = {
              names = [
                "FiraCode Nerd Font"
                "DejaVu Sans Mono"
                "monospace"
              ];
              size = 9.0;
            };

            # Cleaner bar
            trayOutput = "none";
            workspaceButtons = true;
            workspaceNumbers = false;

            colors = {
              background = "#1e1e2e";
              statusline = "#cdd6f4";
              separator = "#585b70";
            };
          }
        ];

        startup = [
          {
            command = "${pkgs.xorg.xrandr}/bin/xrandr --auto";
            always = true;
            notification = false;
          }
          {
            command = "${pkgs.dunst}/bin/dunst";
            always = false;
            notification = false;
          }

          {
            command = "${pkgs.networkmanagerapplet}/bin/nm-applet";
            always = false;
            notification = false;
          }

          {
            command = "${pkgs.xorg.xset}/bin/xset s off -dpms";
            always = true;
            notification = false;
          }
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
            # Apps
            "${mod}+t" = "exec ${pkgs.${profile.desktop.terminal}}/bin/${profile.desktop.terminal}";
            "${mod}+r" = "exec ${pkgs.rofi}/bin/rofi -show drun";
            "${mod}+f" = "exec ${pkgs.${profile.desktop.browser}}/bin/${profile.desktop.browser}";

            # Window/session management
            "${mod}+q" = "kill";
            "${mod}+Shift+c" = "reload";
            "${mod}+Shift+r" = "restart";
            "${mod}+Shift+e" = "exec ${pkgs.i3}/bin/i3-msg exit";

            # Lock
            "${mod}+l" = "exec ${lib.getExe lockScreen}";

            # Screenshot: X11 replacement for grim + slurp + wl-copy
            "${mod}+p" = "exec ${lib.getExe screenshotRegion}";

            # Focus movement — preserves your a/d left/right workflow
            "${mod}+a" = "focus left";
            "${mod}+d" = "focus right";
            "${mod}+w" = "focus up";
            "${mod}+s" = "focus down";

            "${mod}+Shift+a" = "move left";
            "${mod}+Shift+d" = "move right";
            "${mod}+Shift+w" = "move up";
            "${mod}+Shift+s" = "move down";

            # Layout controls
            "${mod}+h" = "split h";
            "${mod}+v" = "split v";
            "${mod}+e" = "layout toggle split";

            # Mod+f is LibreWolf, so fullscreen is Shift+f
            "${mod}+Shift+f" = "fullscreen toggle";

            "${mod}+space" = "focus mode_toggle";
            "${mod}+Shift+space" = "floating toggle";

            "${mod}+minus" = "scratchpad show";
            "${mod}+Shift+minus" = "move scratchpad";

            # Resize mode
            "${mod}+BackSpace" = "mode resize";

            # Audio
            "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer -t";
            "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
            "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";

            "F10" = "exec ${pkgs.pamixer}/bin/pamixer -t";
            "F11" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
            "F12" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";

            "XF86AudioMicMute" = "exec ${pkgs.pamixer}/bin/pamixer --default-source -t";

            # Media
            "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
            "XF86AudioPause" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
            "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
            "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";

            # Brightness — usually irrelevant in Hyper-V but safe
            "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";

            "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
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
        # Picture-in-picture behavior.
        for_window [title="Picture-in-Picture"] floating enable, sticky enable

        # Keep transient/dialog windows sane.
        for_window [window_role="pop-up"] floating enable
        for_window [window_role="bubble"] floating enable
        for_window [window_role="task_dialog"] floating enable
        for_window [window_type="dialog"] floating enable
        for_window [window_type="menu"] floating enable
      '';
    };
  };

  home.sessionVariables = {
    TERMINAL = profile.desktop.terminal;
    BROWSER = profile.desktop.browser;
  };
}
