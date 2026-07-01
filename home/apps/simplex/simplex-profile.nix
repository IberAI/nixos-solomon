{config, ...}: {
  solomon.simplex = {
    enable = true;

    profile = "so1omon";

    tor.socksProxy = "127.0.0.1:9050";

    smp = {
      fingerprint = "zXG00lUXLluGvtogTZybjsW6gFtS-YhZorEAi04lksY=";
      onionHost = "3xgiligp6hj2nihtlin6ers2nlqrlce75tm4vn45iufgiywxsba2void.onion";

      passwordFile = "${config.home.homeDirectory}/.config/simplex/smp-password";
    };
  };
}
