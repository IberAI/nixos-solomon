{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkMerge [
    {
      boot.loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };

        efi.canTouchEfiVariables = true;
      };
    }

    (lib.mkIf config.solomon.boot.secureBoot.enable {
      environment.systemPackages = [
        pkgs.sbctl
      ];

      boot.loader.systemd-boot.enable = lib.mkForce false;

      boot.lanzaboote = {
        enable = true;
        pkiBundle = config.solomon.boot.secureBoot.pkiBundle;
      };
    })
  ];
}
