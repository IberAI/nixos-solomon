{
  lib,
  profile,
  ...
}: {
  wayland.windowManager.sway.config = {
    # sway does not inherit services.xserver.xkb, and nixpkgs exports no
    # XKB_DEFAULT_* variables, so the layout has to be handed to the
    # compositor directly. Same profile source as console.keyMap.
    input."*" =
      {
        xkb_layout = profile.keyboard.layout;
        xkb_model = profile.keyboard.model;
      }
      // lib.optionalAttrs (profile.keyboard.variant != "") {
        xkb_variant = profile.keyboard.variant;
      }
      // lib.optionalAttrs (profile.keyboard.options != []) {
        xkb_options = lib.concatStringsSep "," profile.keyboard.options;
      };

    # Override Sway's packaged wallpaper with a plain declarative background.
    output."*".bg = "#1a1b26 solid_color";
  };

  wayland.windowManager.sway.extraConfig = lib.mkAfter ''
    include ~/.config/sway/outputs
  '';
}
