{lib, ...}: {
  options.solomon = {
    user.enable = lib.mkEnableOption "the primary Solomon user account";

    home.enable = lib.mkEnableOption "Home Manager for the primary user";

    desktop.sway.enable = lib.mkEnableOption "the Sway Wayland desktop";

    hardware = {
      bluetooth.enable = lib.mkEnableOption "Bluetooth support";
      nvidia.enable = lib.mkEnableOption "NVIDIA graphics support";
    };

    networking.i2p.enable = lib.mkEnableOption "client-oriented I2P support through i2pd";

    streaming = {
      obs.enable = lib.mkEnableOption "OBS Studio recording and streaming support";
    };
    virtualisation.docker.enable = lib.mkEnableOption "Docker";
  };
}
