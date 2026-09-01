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
    # EDITOR/VISUAL moved to home/dev/nvchad.nix, which is where the editor
    # itself is configured.
    systemPackages = with pkgs; [
      git
      curl
      wget
      vim
      docker-compose
      iproute2
      procps
      lsof
    ];
  };
}
