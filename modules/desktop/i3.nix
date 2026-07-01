{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.solomon.desktop.i3.enable {
    services.xserver.windowManager.i3.enable = true;
  };
}
