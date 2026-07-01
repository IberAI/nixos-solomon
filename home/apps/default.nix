{pkgs, ...}: {
  imports = [
    ./sioyek.nix
    ./simplex/simplex.nix
    ./simplex/simplex-profile.nix
  ];

  home.packages = with pkgs; [
    mullvad-browser
    wireshark
    mpv
    gimp
  ];
  home.sessionVariables = {
    MOZ_LEGACY_PROFILES = "1";
  };
}
