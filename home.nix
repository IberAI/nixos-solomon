{
  lib,
  profile,
  ...
}: {
  imports = [
    ./home/desktop/default.nix
    ./home/apps/default.nix
    ./home/dev/default.nix
  ];

  programs.home-manager.enable = true;

  home = {
    # keep this aligned with when you first started using HM on this machine
    stateVersion = "25.11";

    username = profile.username;
    homeDirectory = profile.homeDirectory;

    activation.createBaseDirs = lib.hm.dag.entryAfter ["writeBoundary"] (
      builtins.readFile ./scripts/create-base-dirs.sh
    );

    sessionPath = [
      "$HOME/.config/emacs/bin/"
    ];
  };

  # Optional but very common quality-of-life:
  # enable XDG base dirs so apps cooperate nicely
  xdg.enable = true;
}
