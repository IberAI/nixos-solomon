{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.solomon.virtualisation.docker.enable {
    virtualisation.docker = {
      enable = true;
      package = pkgs.docker_29;
    };
  };
}
