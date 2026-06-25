{profile, ...}: {
  time.timeZone = profile.locale.timeZone;

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
