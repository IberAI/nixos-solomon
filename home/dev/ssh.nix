{pkgs, profile, ...}: {
  programs.ssh = {
    enable = true;
    package = pkgs.openssh;

    # Stop relying on Home Manager's built-in defaults (they're being removed)
    enableDefaultConfig = false;
    includes = [
      profile.privateIncludes.ssh
    ];

    matchBlocks = {
      # Your "defaults" (applies to all hosts)
      "*" = {
        extraOptions = {
          AddKeysToAgent = "yes";
          ServerAliveInterval = "60";
          ServerAliveCountMax = "3";
          HashKnownHosts = "yes";
        };
      };

      "github.com" = {
        hostname = "github.com";
        user = "git";
      };
    };
  };
}
