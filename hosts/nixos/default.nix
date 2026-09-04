{inputs, ...}: {
  imports = [
    ./hardware-configuration.nix

    inputs.home-manager.nixosModules.default

    ../../profiles/native.nix

    ../../modules/profile.nix

    ../../modules/boot.nix
    ../../modules/nix.nix
    ../../modules/networking.nix
    ../../modules/networking/i2p.nix
    ../../modules/locale.nix
    ../../modules/desktop/sway.nix
    ../../modules/audio.nix
    ../../modules/bluetooth.nix
    ../../modules/graphics/nvidia.nix
    ../../modules/services.nix
    ../../modules/portals.nix
    ../../modules/users.nix
    ../../modules/security.nix
    ../../modules/programs.nix
    ../../modules/streaming/obs.nix
    ../../modules/virtualisation/docker.nix
    ../../modules/home-manager.nix
  ];

  system.stateVersion = "26.05";
}
