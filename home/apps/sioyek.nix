{
  lib,
  pkgs,
  ...
}: {
  programs.sioyek = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "sioyek";
      paths = [pkgs.sioyek];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/sioyek \
          --set QT_QPA_PLATFORM xcb
      '';
    };
  };

  home.activation.createSioyekDir = lib.hm.dag.entryBefore ["writeBoundary"] (
    builtins.readFile ../../scripts/create-sioyek-dir.sh
  );
}
