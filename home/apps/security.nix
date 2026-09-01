{pkgs, ...}: {
  # wireshark is not listed here. It comes from programs.wireshark in
  # modules/security.nix, which is the only way to also get the dumpcap
  # capability wrapper and the group that makes capturing work.
  home.packages = [pkgs.keepassxc];
}
