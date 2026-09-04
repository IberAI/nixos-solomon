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
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_github";
        identitiesOnly = true;
        addKeysToAgent = "yes";
      };

      "codeberg.org codeberg" = {
        hostname = "codeberg.org";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_codeberg";
        identitiesOnly = true;
        addKeysToAgent = "yes";
      };

      "*" = {
        forwardAgent = false;

        serverAliveInterval = 60;
        serverAliveCountMax = 3;

        compression = false;

        addKeysToAgent = "yes";

        hashKnownHosts = true;
        userKnownHostsFile = "~/.ssh/known_hosts";

        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
    };
  };
}
