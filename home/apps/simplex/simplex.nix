{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.solomon.simplex;

  simplexChatCli = pkgs.stdenv.mkDerivation rec {
    pname = "simplex-chat-cli";
    inherit (cfg) version;

    src = pkgs.fetchurl {
      url = "https://github.com/simplex-chat/simplex-chat/releases/download/v${version}/simplex-chat-ubuntu-24_04-x86_64";
      inherit (cfg) hash;
    };

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = with pkgs; [
      glibc
      gmp
      zlib
      openssl
      ncurses
      libffi
      sqlite
      sqlcipher
    ];

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 "$src" "$out/bin/simplex-chat"

      wrapProgram "$out/bin/simplex-chat" \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath buildInputs}"

      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "SimpleX Chat terminal CLI packaged from the official upstream binary";
      homepage = "https://simplex.chat";
      license = licenses.agpl3Only;
      platforms = ["x86_64-linux"];
      mainProgram = "simplex-chat";
    };
  };

  simplexTor = pkgs.writeShellApplication {
    name = "simplex-tor";

    runtimeInputs = with pkgs; [
      coreutils
    ];

    text = ''
      set -euo pipefail

      config_file="${cfg.smpConfigFile}"

      if [ ! -r "$config_file" ]; then
        echo "simplex-tor: config file is missing or unreadable: $config_file" >&2
        exit 1
      fi

      set -a
      # shellcheck disable=SC1090
      . "$config_file"
      set +a

      : "''${SIMPLEX_SMP_FINGERPRINT:?missing SIMPLEX_SMP_FINGERPRINT}"
      : "''${SIMPLEX_SMP_ONION_HOST:?missing SIMPLEX_SMP_ONION_HOST}"
      : "''${SIMPLEX_SMP_PASSWORD:?missing SIMPLEX_SMP_PASSWORD}"

      exec ${simplexChatCli}/bin/simplex-chat \
        -d "$HOME/.simplex/${cfg.profile}" \
        --socks-proxy="${cfg.tor.socksProxy}" \
        -s "smp://$SIMPLEX_SMP_FINGERPRINT:$SIMPLEX_SMP_PASSWORD@$SIMPLEX_SMP_ONION_HOST"
    '';
  };
in {
  options.solomon.simplex = {
    enable = lib.mkEnableOption "SimpleX Chat CLI wrapper";

    version = lib.mkOption {
      type = lib.types.str;
      default = "6.5.5";
      description = "SimpleX Chat CLI version.";
    };

    hash = lib.mkOption {
      type = lib.types.str;
      default = "sha256-CdilJpSKNssEKywdBBdNf+YLUZusjwvTN0vM0aiLmZE=";
      description = "Nix SRI hash for the upstream SimpleX Chat CLI binary.";
    };

    profile = lib.mkOption {
      type = lib.types.str;
      default = "main";
      description = "SimpleX local profile/database name.";
    };

    smpConfigFile = lib.mkOption {
      type = lib.types.str;
      default = "\${HOME}/.config/simplex/smp.env";
      description = "Runtime path to a private shell env file with SMP connection values.";
    };

    tor.socksProxy = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:9050";
      description = "Tor SOCKS proxy used by SimpleX.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      simplexChatCli
      simplexTor
      pkgs.tmux
    ];
  };
}
