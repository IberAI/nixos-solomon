{
  pkgs,
  profile,
  ...
}: {
  programs.ssh = {
    enable = true;
    package = pkgs.openssh;

    # Stop relying on Home Manager's old defaults.
    enableDefaultConfig = false;

    # This gets emitted near the top of ~/.ssh/config.
    includes = [
      profile.privateIncludes.ssh
    ];

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
        HashKnownHosts = true;

        # Explicitly preserve sane old/default-ish values.
        ForwardAgent = false;
        Compression = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };

      "github.com" = {
        HostName = "github.com";
        User = "git";
      };
    };
  };
}
