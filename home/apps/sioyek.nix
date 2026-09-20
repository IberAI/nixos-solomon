{
  pkgs,
  lib,
  ...
}: {
  programs.sioyek = {
    enable = true;

    package = pkgs.symlinkJoin {
      name = "sioyek-nvidia";
      paths = [pkgs.sioyek];

      nativeBuildInputs = [pkgs.makeWrapper];

      postBuild = ''
        wrapProgram $out/bin/sioyek \
          --set QT_QPA_PLATFORM xcb \
          --set __GLX_VENDOR_LIBRARY_NAME nvidia
      '';
    };

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
