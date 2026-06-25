_: {
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
    };

    polkit.enable = true;

    pam.services.i3lock.enable = true;
  };
}
