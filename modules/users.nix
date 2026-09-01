{
  config,
  lib,
  pkgs,
  profile,
  ...
}: {
  config = lib.mkIf config.solomon.user.enable {
    users.users.${profile.username} = {
      isNormalUser = true;
      description = profile.username;

      extraGroups = [
        "wheel"
        "audio"
        "video"
        "networkmanager"
        "docker"
        # Required to use the dumpcap wrapper from programs.wireshark.
        "wireshark"
      ];

      shell = pkgs.fish;
    };
  };
}
