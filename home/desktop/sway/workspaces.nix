_: {
  wayland.windowManager.sway.config.workspaceOutputAssign =
    map (number: {
      workspace = toString number;
      output = ["DP-1" "HDMI-A-1"];
    }) [1 2 3 4 5]
    ++ map (number: {
      workspace = toString number;
      output = ["HDMI-A-1" "DP-1"];
    }) [6 7 8 9];
}
