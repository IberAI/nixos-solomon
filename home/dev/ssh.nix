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
      # Global options (formerly Host "*")
      "*" = {
        ForwardAgent = false;
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
        Compression = false;
        AddKeysToAgent = "yes";
        HashKnownHosts = true;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };

      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519_github";
        IdentitiesOnly = true;
        AddKeysToAgent = "yes";
      };

      "codeberg.org" = {
        HostName = "codeberg.org";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519_codeberg";
        IdentitiesOnly = true;
        AddKeysToAgent = "yes";
      };

      "codeberg" = {
        HostName = "codeberg.org";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519_codeberg";
        IdentitiesOnly = true;
        AddKeysToAgent = "yes";
      };
    };
  };
}
