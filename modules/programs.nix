{pkgs, ...}: {
  programs = {
    fish.enable = true;
    nm-applet.enable = true;
    nix-ld.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
    };
  };

  environment = {
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    systemPackages = with pkgs; [
      git
      curl
      wget
      vim
      docker-compose

      xorg.xrandr
      xorg.xset
      xorg.xprop
      xorg.xwininfo
      xorg.setxkbmap
      xorg.xev
      xorg.xmodmap
      xorg.xkeyboardconfig

      iproute2
      procps
      lsof

      i3
      i3status
      i3lock
      rofi
      xclip
      xsel
    ];
  };
}
