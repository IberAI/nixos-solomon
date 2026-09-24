{lib, ...}: {
  programs.sioyek = {
    enable = true;
  };

  home.activation.createSioyekDir = lib.hm.dag.entryBefore ["writeBoundary"] (
    builtins.readFile ../../scripts/create-sioyek-dir.sh
  );
}
