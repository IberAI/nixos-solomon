{
  lib,
  pkgs,
  ...
}: let
  inherit (import ./commands.nix {inherit pkgs;}) lockScreen;
  lockCommand = "${lib.getExe lockScreen} --daemonize";
in {
  services.swayidle = {
    enable = true;
    systemdTargets = ["sway-session.target"];
    extraArgs = ["-w"];

    timeouts = [
      {
        timeout = 600;
        command = lockCommand;
      }
    ];

    events = {
      before-sleep = lockCommand;
      lock = lockCommand;
    };
  };
}
