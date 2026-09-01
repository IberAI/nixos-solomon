{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.solomon.streaming.obs.enable {
    programs.obs-studio = {
      enable = true;
      package = pkgs.obs-studio;
      enableVirtualCamera = true;

      plugins = with pkgs.obs-studio-plugins; [
        input-overlay
        obs-pipewire-audio-capture
        obs-vertical-canvas
        wlrobs
      ];
    };

    # QT_QPA_PLATFORM is not set here. It is a session-wide display-server
    # variable and belongs to modules/desktop/sway.nix; declaring it in two
    # modules only works for as long as both strings stay identical.
  };
}
