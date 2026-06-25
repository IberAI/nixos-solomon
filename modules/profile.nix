{lib, ...}: {
  options.solomon = {
    user.enable = lib.mkEnableOption "the primary Solomon user account";

    home.enable = lib.mkEnableOption "Home Manager for the primary user";

    desktop = {
      x11.enable = lib.mkEnableOption "the X11 desktop base";
      i3.enable = lib.mkEnableOption "the i3 window manager";
    };

    hyperv = {
      guest.enable = lib.mkEnableOption "Hyper-V guest integration";
      enhancedSession.enable = lib.mkEnableOption "Hyper-V Enhanced Session Mode through xrdp";
    };

    virtualisation.docker.enable = lib.mkEnableOption "Docker";
  };
}
