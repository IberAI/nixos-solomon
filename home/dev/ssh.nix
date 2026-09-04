{
  pkgs,
  profile,
  ...
}: {
  programs.ssh = {
    enable = true;
    package = pkgs.openssh;

    enableDefaultConfig = false;

    includes = [
      profile.privateIncludes.ssh
    ];

    settings = {
      "github.com" = {
        IdentitiesOnly = true;
        User = "git";
        HostName = "github.com";
        IdentityFile = "~/.ssh/id_ed25519_github";
      };

      "*" = {
        ForwardAgent = false;
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
        Compression = false;
        AddKeysToAgent = true;
        HashKnownHosts = true;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };
  };
}
