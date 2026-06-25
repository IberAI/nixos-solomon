_: {
  solomon = {
    user.enable = true;
    home.enable = true;

    desktop = {
      x11.enable = true;
      i3.enable = true;
    };

    hyperv = {
      guest.enable = true;
      enhancedSession.enable = true;
    };

    virtualisation.docker.enable = true;
  };
}
