{pkgs, profile, ...}: {
  networking = {
    hostName = profile.hostName;

    networkmanager = {
      enable = true;

      plugins = with pkgs; [
        networkmanager-openconnect
      ];
    };

    firewall = {
      enable = true;
    };
  };
}
