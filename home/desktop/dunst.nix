{pkgs, ...}: {
  services.dunst = {
    enable = true;
    package = pkgs.dunst;

    settings = {
      global = {
        monitor = 0;
        follow = "mouse";

        # Modern replacement for:
        # geometry = "300x8-20+40";
        width = 300;
        height = 300;
        origin = "top-right";
        offset = "20x40";

        indicate_hidden = true;
        shrink = false;
        transparency = 0;

        notification_height = 0;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        frame_width = 2;

        sort = true;

        font = "FiraCode Nerd Font 10";
        markup = "yes";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";

        idle_threshold = 120;
        show_age_threshold = 60;
        ignore_newline = false;

        icon_position = "left";
        max_icon_size = 32;

        # Open notification links in Mullvad Browser
        browser = "${pkgs.mullvad-browser}/bin/mullvad-browser";
      };

      urgency_low = {
        background = "#222222";
        foreground = "#dddddd";
        frame_color = "#444444";
        timeout = 5;
      };

      urgency_normal = {
        background = "#222222";
        foreground = "#ffffff";
        frame_color = "#5e81ac";
        timeout = 8;
      };

      urgency_critical = {
        background = "#2f0000";
        foreground = "#ffffff";
        frame_color = "#bf616a";

        # Do not stick forever.
        timeout = 15;
      };
    };
  };
}
