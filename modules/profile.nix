{lib, ...}: {
  options.solomon = {
    user.enable = lib.mkEnableOption "the primary Solomon user account";

    home.enable = lib.mkEnableOption "Home Manager for the primary user";

    desktop.sway.enable = lib.mkEnableOption "the Sway Wayland desktop";

    hardware = {
      bluetooth.enable = lib.mkEnableOption "Bluetooth support";
      nvidia.enable = lib.mkEnableOption "NVIDIA graphics support";
    };

    networking.i2p.enable = lib.mkEnableOption "client-oriented I2P support through i2pd";

    streaming = {
      gpuScreenRecorder = {
        enable = lib.mkEnableOption "GPU Screen Recorder, a low-overhead GPU-encoded recorder and streamer";

        targets = lib.mkOption {
          default = {};

          description = ''
            Named live-stream destinations. Each entry generates a
            `stream-<name>` command that reads its secret from {option}`keyFile`
            at run time and hands the assembled URL to GPU Screen Recorder.
          '';

          example = lib.literalExpression ''
            {
              twitch = {
                url = "rtmp://live.twitch.tv/app";
                bitrate = 6000;
              };
            }
          '';

          type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
            options = {
              url = lib.mkOption {
                type = lib.types.str;
                example = "rtmp://live.twitch.tv/app";
                description = "Ingest URL of the service, without the stream key.";
              };

              keyFile = lib.mkOption {
                type = lib.types.str;
                default = "$HOME/.config/gpu-screen-recorder/${name}.key";
                defaultText = lib.literalExpression ''"$HOME/.config/gpu-screen-recorder/<name>.key"'';
                description = ''
                  Path of the file holding the stream key, read at run time.
                  Shell expansion applies, so `$HOME` works. Never point this at
                  a path inside the Nix store: the store is world readable.
                '';
              };

              capture = lib.mkOption {
                type = lib.types.str;
                default = "screen";
                example = "portal";
                description = ''
                  Capture source passed to `-w`. `screen` uses KMS capture,
                  `portal` goes through xdg-desktop-portal instead.
                '';
              };

              audio = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = ["default_output"];
                example = ["default_output" "default_input"];
                description = "Audio sources, each passed as its own `-a` flag.";
              };

              framerate = lib.mkOption {
                type = lib.types.ints.positive;
                default = 60;
                description = "Capture frame rate.";
              };

              bitrate = lib.mkOption {
                type = lib.types.ints.positive;
                default = 8000;
                description = "Constant bitrate in kbps.";
              };

              videoCodec = lib.mkOption {
                type = lib.types.enum ["h264" "hevc" "av1"];
                default = "h264";
                description = "Video codec. h264 is the safe choice for RTMP ingests.";
              };

              audioCodec = lib.mkOption {
                type = lib.types.enum ["aac" "opus" "flac"];
                default = "aac";
                description = "Audio codec. aac is the safe choice for RTMP ingests.";
              };

              extraArgs = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [];
                example = ["-cursor" "no"];
                description = "Extra arguments appended to the recorder invocation.";
              };
            };
          }));
        };
      };
    };
    virtualisation.docker.enable = lib.mkEnableOption "Docker";
  };
}
