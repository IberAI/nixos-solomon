{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.solomon.streaming.gpuScreenRecorder;

  # Upstream's own live-stream invocation is
  #   gpu-screen-recorder -w screen -c flv -a default_output -bm cbr -q 8000 \
  #     -o "rtmp://live.twitch.tv/app/stream_key"
  # (see gpu-screen-recorder(1) EXAMPLES). flv is the container RTMP needs, and
  # -q is a kbps bitrate rather than a preset once -bm is cbr.
  recorderArgs = target:
    ["-w" target.capture]
    ++ lib.concatMap (source: ["-a" source]) target.audio
    ++ [
      "-f"
      (toString target.framerate)
      "-k"
      target.videoCodec
      "-ac"
      target.audioCodec
      "-c"
      "flv"
      "-bm"
      "cbr"
      "-q"
      (toString target.bitrate)
    ]
    # Only meaningful with -w portal, and it is what stops the portal from
    # asking which output to share every single time you go live.
    ++ lib.optionals (target.capture == "portal") ["-restore-portal-session" "yes"]
    ++ target.extraArgs;

  mkStreamScript = name: target:
    pkgs.writeShellApplication {
      name = "stream-${name}";

      runtimeInputs = [
        pkgs.coreutils
        config.programs.gpu-screen-recorder.package
      ];

      text = ''
        key_file="${target.keyFile}"

        if [ ! -r "$key_file" ]; then
          echo "stream-${name}: cannot read stream key file: $key_file" >&2
          echo "stream-${name}: create it with 'install -Dm600 /dev/stdin \"$key_file\"'" >&2
          exit 1
        fi

        mode="$(stat -c %a "$key_file")"
        if [ "$mode" != 600 ] && [ "$mode" != 400 ]; then
          echo "stream-${name}: $key_file is mode $mode, refusing to use it" >&2
          echo "stream-${name}: run 'chmod 600 $key_file'" >&2
          exit 1
        fi

        # The key has to ride along in the RTMP URL, so it is visible in this
        # process's /proc/<pid>/cmdline. Fine for a single-user desktop; do not
        # stream from a box you share with untrusted local accounts.
        exec gpu-screen-recorder ${lib.escapeShellArgs (recorderArgs target)} \
          -o "${target.url}/$(cat "$key_file")" \
          "$@"
      '';
    };
in {
  config = lib.mkIf cfg.enable {
    # Installs the recorder and, crucially, the setcap wrapper for
    # gsr-kms-server. Without the module, KMS capture (the Wayland path) has to
    # ask for privileges on every run.
    programs.gpu-screen-recorder.enable = true;

    environment.systemPackages =
      [pkgs.gpu-screen-recorder-gtk]
      ++ lib.mapAttrsToList mkStreamScript cfg.targets;
  };
}
