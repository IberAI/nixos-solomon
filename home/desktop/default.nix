{pkgs, ...}: {
  imports = [
    ./dunst.nix
    ./fastfetch.nix
    ./i3.nix
    ./i3-rust.nix
  ];

  home.packages = with pkgs; [
    # Launcher
    rofi

    # i3 / X11 tools replacing Wayland tools
    i3
    i3status-rust
    i3lock
    maim
    slop
    xclip

    # Tray / desktop helpers
    udiskie
    adwaita-icon-theme
    networkmanagerapplet
    pavucontrol
    lxappearance
    arandr

    # Notifications
    dunst
    libnotify

    # Controls
    pamixer
    brightnessctl
    playerctl

    # Fonts/icons for i3bar + i3status-rust + fastfetch
    font-awesome
    nerd-fonts.fira-code
    # X11 utilities
    xorg.xset
    xorg.xrandr
    xorg.xprop
    xorg.xwininfo
    xorg.setxkbmap
    xorg.xkeyboardconfig
  ];
}
