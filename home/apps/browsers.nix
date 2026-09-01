{
  pkgs,
  profile,
  ...
}: {
  home = {
    packages = [pkgs.mullvad-browser];

    # Browser-owned variables live with the browser rather than in the desktop
    # module or the shell rc.
    sessionVariables = {
      BROWSER = profile.desktop.browser;
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_LEGACY_PROFILES = "1";
    };
  };
}
