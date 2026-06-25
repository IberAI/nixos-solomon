{
  pkgs,
  lib,
  ...
}: {
  programs.sioyek = {
    enable = true;
    package = pkgs.sioyek;

    # Optional: preferences/bindings if you want to manage them declaratively.
    # config = {
    #   "ui_font_size" = "18";
    # };
    #
    # bindings = {
    #   "j" = "down";
    #   "k" = "up";
    # };
  };

  # Optional: make sure config dir exists (safe)
  home.activation.createSioyekDir = lib.hm.dag.entryBefore ["writeBoundary"] (
    builtins.readFile ../../scripts/create-sioyek-dir.sh
  );
}
