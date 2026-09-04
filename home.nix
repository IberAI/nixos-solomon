{
  lib,
  profile,
  ...
}: {
  imports = [
    ./home/apps/default.nix
    ./home/desktop/default.nix
    ./home/dev/default.nix
    ./home/services/default.nix
  ];

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home = {
    # This branch is for a fresh NixOS 26.05 installation.
    stateVersion = "26.05";

    inherit (profile) username homeDirectory;

    activation.createBaseDirs = lib.hm.dag.entryAfter ["writeBoundary"] (
      builtins.readFile ./scripts/create-base-dirs.sh
    );

    sessionPath = [
      "$HOME/.config/emacs/bin/"
    ];
  };

  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "${profile.homeDirectory}/Desktop";
      documents = "${profile.homeDirectory}/Documents";
      download = "${profile.homeDirectory}/Downloads";
      music = "${profile.homeDirectory}/Media/Music";
      pictures = "${profile.homeDirectory}/Media/Pictures";
      publicShare = "${profile.homeDirectory}/Public";
      templates = "${profile.homeDirectory}/Templates";
      videos = "${profile.homeDirectory}/Media/Videos";

      extraConfig = {
        SCREENSHOTS = "${profile.homeDirectory}/Media/Pictures/ScreenShots";
        DEVELOPMENT = "${profile.homeDirectory}/Development";
        TOOLS = "${profile.homeDirectory}/Tools";
      };
    };
  };
}
