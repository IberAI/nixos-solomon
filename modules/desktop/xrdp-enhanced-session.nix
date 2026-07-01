{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.solomon.hyperv.enhancedSession;

  xrdpI3Session = pkgs.writeShellApplication {
    name = "xrdp-i3-session";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.dbus
      pkgs.i3
      pkgs.xorg.xsetroot
      pkgs.xorg.setxkbmap
    ];
    text = builtins.readFile ../../scripts/xrdp-i3-session.sh;
  };
in {
  config = lib.mkIf cfg.enable {
    services.xrdp = {
      enable = true;
      openFirewall = true;

      defaultWindowManager = lib.getExe xrdpI3Session;

      extraConfDirCommands = ''
        substituteInPlace $out/xrdp.ini \
          --replace-fail 'port=3389' 'port=vsock://-1:3389' \
          --replace-fail '#vmconnect=true' 'vmconnect=true' \
          --replace-fail 'security_layer=negotiate' 'security_layer=rdp' \
          --replace-fail 'crypt_level=high' 'crypt_level=none' \
          --replace-fail 'bitmap_compression=true' 'bitmap_compression=false'

        sed -i '/^rdp_layout_pl=0x00000415$/a rdp_layout_tr=0x0000041F' $out/xrdp_keyboard.ini
        sed -i '/^rdp_layout_pl=pl$/a rdp_layout_tr=tr' $out/xrdp_keyboard.ini

        cp ${../../assets/xrdp/km-0000041f.ini} $out/km-0000041f.ini
      '';
    };

    systemd.services.xrdp.serviceConfig.ExecStart =
      lib.mkForce "${pkgs.xrdp}/bin/xrdp --nodaemon --config /etc/xrdp/xrdp.ini";
  };
}
