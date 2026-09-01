{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.solomon.hardware.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings = {
        General = {
          Experimental = true;
          KernelExperimental = true;
        };
      };
    };

    services.blueman.enable = true;

    environment.systemPackages = with pkgs; [
      bluez
      bluez-tools
    ];
  };
}
