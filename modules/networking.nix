{
  pkgs,
  profile,
  ...
}: {
  networking = {
    inherit (profile) hostName;

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
