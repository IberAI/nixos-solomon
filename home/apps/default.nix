{pkgs, ...}: {
  imports = [
    ./sioyek.nix
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
