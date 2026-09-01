{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.solomon.networking.i2p.enable {
    services.i2pd = {
      enable = true;
      package = pkgs.i2pd;

      logLevel = "warn";
      enableIPv4 = true;
      enableIPv6 = false;
      notransit = true;
      floodfill = false;
      upnp.enable = false;
      bandwidth = 256;

      ntcp2 = {
        enable = true;
        published = false;
        port = 0;
      };

      ssu2 = {
        enable = true;
        published = false;
        port = 0;
      };

      proto = {
        http = {
          enable = true;
          address = "127.0.0.1";
          port = 7070;
          strictHeaders = true;
          hostname = "127.0.0.1";
        };

        httpProxy = {
          enable = true;
          address = "127.0.0.1";
          port = 4444;
        };

        socksProxy = {
          enable = true;
          address = "127.0.0.1";
          port = 4447;
          outproxyEnable = false;
        };

        sam = {
          enable = true;
          address = "127.0.0.1";
          port = 7656;
        };

        i2cp = {
          enable = true;
          address = "127.0.0.1";
          port = 7654;
        };
      };
    };

    environment.systemPackages = [
      pkgs.i2pd
    ];
  };
}
