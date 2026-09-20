{
  pkgs,
  lib,
  ...
}: {
  programs.sioyek = {
    enable = true;
    package = pkgs.writeShellScriptBin "sioyek" ''
      export QT_QPA_PLATFORM=xcb
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      exec ${pkgs.sioyek}/bin/sioyek "$@"
    '';
    # Optional: preferences/bindings if you want to manage them declaratively.
    # config = {
    #   ui_font_size = "18";
    # };
    #
    # bindings = {
    #   j = "down";
    #   k = "up";
    # };
  };

  home.activation.createSioyekDir = lib.hm.dag.entryBefore ["writeBoundary"] (
    builtins.readFile ../../scripts/create-sioyek-dir.sh
  );
}
