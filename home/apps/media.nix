{pkgs, ...}: {
  imports = [
    ./sioyek.nix
  ];

  home.packages = with pkgs; [
    newsboat
    mpv
    yt-dlp
  ];
}
