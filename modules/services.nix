_: {
  services = {
    udisks2.enable = true;
    gvfs.enable = true;
    upower.enable = true;

    tor = {
      enable = true;
      client.enable = true;

      settings = {
        AutomapHostsOnResolve = true;
        VirtualAddrNetworkIPv4 = "10.192.0.0/10";
      };
    };
  };
}
