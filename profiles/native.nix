_: {
  solomon = {
    user.enable = true;
    home.enable = true;

    desktop.sway.enable = true;

    hardware = {
      bluetooth.enable = true;
      nvidia.enable = true;
    };

    networking.i2p.enable = true;

    streaming = {
      gpuScreenRecorder = {
        enable = true;

        # Add a destination here to get a `stream-<name>` command. The key never
        # belongs in this file; it is read at run time from keyFile, which
        # defaults to ~/.config/gpu-screen-recorder/<name>.key (mode 600).
        #
        # targets.twitch = {
        #   url = "rtmp://live.twitch.tv/app";
        #   bitrate = 6000;
        # };
        targets = {};
      };
    };

    virtualisation.docker.enable = true;
  };
}
