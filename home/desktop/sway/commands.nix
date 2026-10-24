{pkgs}: {
  lockScreen = pkgs.writeShellApplication {
    name = "sway-lock-screen";
    runtimeInputs = [pkgs.swaylock];
    text = ''
      exec swaylock --color 1e1e2e --indicator-idle-visible --ring-color 89b4fa --key-hl-color a6e3a1 "$@"
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
}
