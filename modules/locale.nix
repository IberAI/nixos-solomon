{
  lib,
  profile,
  ...
}: {
  time.timeZone = profile.locale.timeZone;

  # lib/profile.nix declares the keyboard, but nothing consumed it, so the
  # machine came up as the "us"/"pc104" defaults everywhere. There are three
  # separate consumers and no single option feeds all of them:
  #
  #   - the Linux console, which is what greetd/tuigreet renders the password
  #     prompt on, reads console.keyMap
  #   - X11 clients under XWayland read services.xserver.xkb
  #   - sway reads neither; nixpkgs exports no XKB_DEFAULT_* variables, so the
  #     compositor is configured from home/desktop/sway.nix instead
  #
  # All three derive from the same profile attributes, so they cannot drift.
  console.keyMap = profile.keyboard.consoleKeyMap;

  services.xserver.xkb =
    {
      inherit (profile.keyboard) layout model variant;
    }
    // lib.optionalAttrs (profile.keyboard.options != []) {
      options = lib.concatStringsSep "," profile.keyboard.options;
    };

  i18n = {
    defaultLocale = profile.locale.default;

    extraLocaleSettings = {
      LC_ADDRESS = profile.locale.default;
      LC_IDENTIFICATION = profile.locale.default;
      LC_MEASUREMENT = profile.locale.default;
      LC_MONETARY = profile.locale.default;
      LC_NAME = profile.locale.default;
      LC_NUMERIC = profile.locale.default;
      LC_PAPER = profile.locale.default;
      LC_TELEPHONE = profile.locale.default;
      LC_TIME = profile.locale.default;
    };
  };
}
