_: {
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "never";

    settings = {
      program_options = {
        udisks_version = 2;
      };
    };
  };

  systemd.user.services.udiskie.Service = {
    Restart = "on-failure";
    RestartSec = "5s";
  };
}
