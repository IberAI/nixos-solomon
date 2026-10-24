{config, ...}: let
  mod = config.wayland.windowManager.sway.config.modifier;
in {
  wayland.windowManager.sway.config = {
    window = {
      border = 2;
      titlebar = false;
      hideEdgeBorders = "smart";
    };

    floating = {
      border = 2;
      titlebar = true;
      modifier = mod;

      criteria = [
        {app_id = "pavucontrol";}
        {app_id = "blueman-manager";}
        {app_id = "nm-connection-editor";}
        {title = "Picture-in-Picture";}
        {window_role = "dialog";}
        {window_type = "dialog";}
        {window_type = "menu";}
      ];
    };

    focus = {
      followMouse = false;
      wrapping = "yes";
      newWindow = "smart";
      mouseWarping = false;
    };

    workspaceAutoBackAndForth = true;
    workspaceLayout = "default";
  };

  wayland.windowManager.sway.extraConfig = ''
    for_window [title="Picture-in-Picture"] floating enable, sticky enable
    for_window [window_role="pop-up"] floating enable
    for_window [window_role="bubble"] floating enable
    for_window [window_role="task_dialog"] floating enable
    for_window [window_type="dialog"] floating enable
    for_window [window_type="menu"] floating enable
  '';
}
