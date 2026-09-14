{pkgs, ...}: {
  imports = [
    ./sioyek.nix
  ];

  home.packages = with pkgs; [
    mpv
    yt-dlp
  ];
}
