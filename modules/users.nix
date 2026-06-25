{config, lib, pkgs, profile, ...}: {
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
      ];

      shell = pkgs.fish;
    };
  };
}
