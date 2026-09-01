{pkgs, ...}: {
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
    };

    polkit.enable = true;
  };

  # Installing the wireshark package alone is not enough to capture anything:
  # the module is what creates the 'wireshark' group and the setcap wrapper for
  # dumpcap (cap_net_raw,cap_net_admin+eip). Without it Wireshark starts but
  # lists no interfaces. The default package here is wireshark-cli, so the GUI
  # has to be requested explicitly.
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
}
