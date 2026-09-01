_: {
  # Everything else this file used to declare is already supplied by
  # programs.sway.enable, via nixos/modules/programs/wayland/sway.nix and its
  # wayland-session.nix import:
  #
  #   - xdg.portal.wlr.enable = true
  #   - xdg.portal.extraPortals = [ xdg-desktop-portal-gtk ]
  #   - xdg.portal.config.sway = { default = ["gtk"]; ScreenCast/Screenshot =
  #     "wlr"; Inhibit = "none"; }
  #
  # Restating them here only produced duplicate extraPortals entries and a
  # second definition of every config.sway key, which merges today purely
  # because the values happen to match upstream verbatim.
  xdg.portal.enable = true;
}
