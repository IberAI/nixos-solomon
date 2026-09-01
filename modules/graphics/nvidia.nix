{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.solomon.hardware.nvidia.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # NixOS uses this selector for the NVIDIA driver even on Wayland-only systems.
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      branch = "production";
      open = true;
      modesetting.enable = true;
      nvidiaSettings = true;
      powerManagement.enable = true;
    };
  };
}
