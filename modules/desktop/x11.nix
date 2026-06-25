{
  config,
  lib,
  profile,
  ...
}: let
  cfg = config.solomon.desktop.x11;
  inherit (profile) keyboard;
in {
  config = lib.mkIf cfg.enable {
    console.keyMap = keyboard.consoleKeyMap;

    services.xserver = {
      enable = true;

      xkb = {
        inherit (keyboard) layout model variant;
        options = lib.concatStringsSep "," keyboard.options;
      };

      displayManager.lightdm.enable = false;
      displayManager.startx.enable = true;
    };
  };
}
