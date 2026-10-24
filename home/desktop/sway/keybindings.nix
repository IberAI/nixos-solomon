{
  config,
  lib,
  pkgs,
  profile,
  ...
}: let
  inherit (builtins) toString;
  inherit (config.wayland.windowManager.sway.config) terminal;
  mod = config.wayland.windowManager.sway.config.modifier;
  launcher = config.wayland.windowManager.sway.config.menu;
  browser = lib.getExe pkgs.${profile.desktop.browser};
  inherit (import ./commands.nix {inherit pkgs;}) lockScreen screenshotRegion;

  mkWorkspaceBindings = num: let
    n = toString num;
  in {
    "${mod}+${n}" = "workspace number ${n}";
    "${mod}+Shift+${n}" = "move container to workspace number ${n}";
  };
in {
  wayland.windowManager.sway.config = {
    keybindings = lib.mkForce (
      mkWorkspaceBindings 1
      // mkWorkspaceBindings 2
      // mkWorkspaceBindings 3
      // mkWorkspaceBindings 4
      // mkWorkspaceBindings 5
      // mkWorkspaceBindings 6
      // mkWorkspaceBindings 7
      // mkWorkspaceBindings 8
      // mkWorkspaceBindings 9
      // {
        "${mod}+t" = "exec ${terminal}";
        # Open Rofi's desktop-application launcher with Super/Windows + R.
        "${mod}+r" = "exec ${launcher}";
        "${mod}+f" = "exec ${browser}";
        "${mod}+o" = "exec ${lib.getExe pkgs.nwg-displays} --num_ws 9";

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
}
