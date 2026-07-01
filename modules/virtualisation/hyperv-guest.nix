{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.solomon.hyperv.guest.enable {
    virtualisation.hypervGuest.enable = true;
  };
}
