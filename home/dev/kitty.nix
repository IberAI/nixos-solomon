# home/apps/kitty.nix
{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;

    font = {
      # Make sure Maple Mono NF is installed somewhere in your config.
      # If it is not available, switch this to "FiraCode Nerd Font".
      name = "Maple Mono NF";
      size = 10;
    };

    shellIntegration = {
      enableFishIntegration = true;
      mode = "no-rc";
    };

    settings = {
      ########################################
      # Core behavior
      ########################################

      confirm_os_window_close = 0;
      enable_audio_bell = false;
      visual_bell_duration = "0.0";

      scrollback_lines = 10000;
      wheel_scroll_multiplier = 3.0;

      ########################################
      # i3/X11-friendly window behavior
      ########################################

      remember_window_size = false;
      initial_window_width = 1000;
      initial_window_height = 650;

      # i3 already handles outer gaps/borders.
      window_padding_width = 4;
      window_margin_width = 0;

      hide_window_decorations = true;

      ########################################
      # Clipboard / mouse
      ########################################

      copy_on_select = "clipboard";
      strip_trailing_spaces = "smart";
      mouse_hide_wait = 3.0;
      focus_follows_mouse = false;

      ########################################
      # URL handling
      ########################################
      # Kitty will use xdg-open/default browser.
      # Your shell/i3 config sets BROWSER=mullvad-browser.

      open_url_with = "default";
      detect_urls = true;
      show_hyperlink_targets = "yes";

      ########################################
      # Cursor
      ########################################

      cursor_shape = "beam";
      cursor_blink_interval = 0.5;
      cursor_stop_blinking_after = 15.0;

      ########################################
      # Theme
      ########################################

      foreground = "#cdd6f4";
      background = "#1e1e2e";

      selection_foreground = "#11111b";
      selection_background = "#89b4fa";

      cursor = "#f5e0dc";
      cursor_text_color = "#1e1e2e";

      active_border_color = "#5cedaa";
      inactive_border_color = "#45475a";
      bell_border_color = "#f38ba8";

      active_tab_foreground = "#11111b";
      active_tab_background = "#89b4fa";

      inactive_tab_foreground = "#cdd6f4";
      inactive_tab_background = "#313244";

      ########################################
      # Layouts
      ########################################
      # First layout is default.
      # tall:bias=70 gives your preferred 70/30 main-pane workflow.

      enabled_layouts = "tall:bias=70;full_size=1,grid,stack,splits";

      ########################################
      # Tabs
      ########################################

      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_bar_min_tabs = 1;
      tab_bar_align = "left";

      tab_title_template = "{index}: {title}{' [{}]'.format(num_windows) if num_windows > 1 else ''}";
    };

    keybindings = {
      ########################################
      # Tabs
      ########################################

      "ctrl+shift+n" = "new_tab";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+q" = "close_tab";

      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";

      "ctrl+shift+1" = "goto_tab 1";
      "ctrl+shift+2" = "goto_tab 2";
      "ctrl+shift+3" = "goto_tab 3";
      "ctrl+shift+4" = "goto_tab 4";
      "ctrl+shift+5" = "goto_tab 5";
      "ctrl+shift+6" = "goto_tab 6";
      "ctrl+shift+7" = "goto_tab 7";
      "ctrl+shift+8" = "goto_tab 8";
      "ctrl+shift+9" = "goto_tab 9";

      "ctrl+." = "move_tab_forward";
      "ctrl+comma" = "move_tab_backward";

      ########################################
      # Windows / panes
      ########################################

      "ctrl+shift+enter" = "new_window";
      "ctrl+shift+w" = "close_window";

      "ctrl+shift+]" = "next_window";
      "ctrl+shift+[" = "previous_window";

      "ctrl+right" = "neighboring_window right";
      "ctrl+left" = "neighboring_window left";
      "ctrl+up" = "neighboring_window up";
      "ctrl+down" = "neighboring_window down";

      "ctrl+alt+h" = "neighboring_window left";
      "ctrl+alt+j" = "neighboring_window down";
      "ctrl+alt+k" = "neighboring_window up";
      "ctrl+alt+l" = "neighboring_window right";

      # Explicit split creation.
      "ctrl+shift+minus" = "launch --location=hsplit --cwd=current";
      "ctrl+shift+backslash" = "launch --location=vsplit --cwd=current";

      "ctrl+shift+r" = "start_resizing_window";

      "ctrl+1" = "nth_window 0";
      "ctrl+2" = "nth_window 1";
      "ctrl+3" = "nth_window 2";
      "ctrl+4" = "nth_window 3";
      "ctrl+5" = "nth_window 4";
      "ctrl+6" = "nth_window 5";
      "ctrl+7" = "nth_window 6";
      "ctrl+8" = "nth_window 7";
      "ctrl+9" = "nth_window 8";

      ########################################
      # Layouts
      ########################################

      "ctrl+alt+t" = "goto_layout tall:bias=70;full_size=1";
      "ctrl+alt+g" = "goto_layout grid";
      "ctrl+alt+s" = "goto_layout stack";
      "ctrl+alt+x" = "goto_layout splits";

      ########################################
      # Font sizing
      ########################################

      "ctrl+shift+plus" = "change_font_size all +1.0";
      "ctrl+shift+equal" = "change_font_size all +1.0";
      "ctrl+shift+underscore" = "change_font_size all -1.0";
      "ctrl+shift+0" = "change_font_size all 0";

      ########################################
      # Clipboard / search / extras
      ########################################

      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";

      "ctrl+shift+u" = "kitten unicode_input";
      "ctrl+shift+f" = "show_scrollback";
    };

    extraConfig = ''
      # Keep extraConfig minimal.
      # Anything here overrides Home Manager-generated kitty.conf lines.
    '';
  };
}
