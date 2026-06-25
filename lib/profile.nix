rec {
  system = "x86_64-linux";

  username = "solomon";
  hostName = "nixos";
  homeDirectory = "/home/${username}";

  locale = {
    timeZone = "Asia/Jerusalem";
    default = "en_US.UTF-8";
  };

  keyboard = {
    layout = "tr";
    model = "pc105";
    variant = "";
    options = [];
    consoleKeyMap = "trq";
  };

  desktop = {
    terminal = "kitty";
    browser = "mullvad-browser";
  };

  privateIncludes = {
    git = "~/.config/git/local.inc";
    ssh = "~/.ssh/config.local";
  };
}
