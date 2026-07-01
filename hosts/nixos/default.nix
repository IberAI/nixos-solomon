{inputs, ...}: {
  imports = [
    ./hardware-configuration.nix

    inputs.home-manager.nixosModules.default

    ../../profiles/hyperv-vm.nix

    ../../modules/profile.nix

    ../../modules/boot.nix
    ../../modules/nix.nix
    ../../modules/networking.nix
    ../../modules/locale.nix
    ../../modules/desktop/x11.nix
    ../../modules/desktop/i3.nix
    ../../modules/desktop/xrdp-enhanced-session.nix
    ../../modules/audio.nix
    ../../modules/services.nix
    ../../modules/portals.nix
    ../../modules/users.nix
    ../../modules/security.nix
    ../../modules/programs.nix
    ../../modules/virtualisation/docker.nix
    ../../modules/virtualisation/hyperv-guest.nix
    ../../modules/home-manager.nix
  ];

  system.stateVersion = "25.11";
}
