_: {
  wayland.windowManager.sway.config = {
    fonts = {
      names = [
        # pkgs.font-awesome is 7.x, whose families are "Font Awesome 7 *".
        # The old 6 name matched nothing and silently fell through.
        "Font Awesome 7 Free"
        "FiraCode Nerd Font"
        "DejaVu Sans Mono"
        "monospace"
      ];
      size = 10.0;
    };

    gaps = {
      inner = 8;
      outer = 4;
      smartGaps = true;
      smartBorders = "on";
    };

    colors = {
      background = "#1e1e2e";

      focused = {
        border = "#89b4fa";
        childBorder = "#89b4fa";
        background = "#89b4fa";
        text = "#11111b";
        indicator = "#89b4fa";
      };

      focusedInactive = {
        border = "#45475a";
        childBorder = "#45475a";
        background = "#313244";
        text = "#cdd6f4";
        indicator = "#45475a";
      };

      unfocused = {
        border = "#313244";
        childBorder = "#313244";
        background = "#1e1e2e";
        text = "#a6adc8";
        indicator = "#313244";
      };

      urgent = {
        border = "#f38ba8";
        childBorder = "#f38ba8";
        background = "#f38ba8";
        text = "#11111b";
        indicator = "#f38ba8";
      };

      placeholder = {
        border = "#585b70";
        childBorder = "#585b70";
        background = "#1e1e2e";
        text = "#cdd6f4";
        indicator = "#585b70";
      };
    };
  };
}
