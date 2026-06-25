{pkgs, ...}: {
  programs.i3status-rust = {
    enable = true;
    package = pkgs.i3status-rust;

    bars = {
      top = {
        icons = "awesome6";
        theme = "gruvbox-dark";

        blocks = [
          {
            block = "cpu";
            interval = 5;
          }

          {
            block = "memory";
            interval = 10;
          }

          {
            block = "sound";
            driver = "pulseaudio";
          }

          {
            block = "time";
            interval = 60;
            format = " $timestamp.datetime(f:'%a %H:%M') ";
          }
        ];
      };
    };
  };
}
