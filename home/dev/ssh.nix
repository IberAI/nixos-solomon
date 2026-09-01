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

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
        hashKnownHosts = true;

        forwardAgent = false;
        compression = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };

      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github";
        identitiesOnly = true;
      };

      "codeberg.org" = {
        hostname = "codeberg.org";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_codeberg";
        identitiesOnly = true;
      };
    };
  };
}
