{pkgs, ...}: {
  services.mako = {
    enable = true;
    package = pkgs.mako;

    settings = {
      font = "FiraCode Nerd Font 10";
      width = 320;
      height = 180;
      margin = "16";
      padding = "10";
      border-size = 2;
      border-radius = 4;
      default-timeout = 8000;
      ignore-timeout = false;
      layer = "overlay";
      anchor = "top-right";

      background-color = "#1e1e2e";
      text-color = "#cdd6f4";
      border-color = "#89b4fa";

      "urgency=critical" = {
        background-color = "#2f0000";
        text-color = "#ffffff";
        border-color = "#f38ba8";
        default-timeout = 15000;
      };
    };
  };
}
