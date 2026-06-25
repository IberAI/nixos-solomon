{pkgs, profile, ...}: {
  programs.gpg.enable = true;

  programs.git = {
    enable = true;
    package = pkgs.git;

    settings = {
      alias = {
        st = "status -sb";
        co = "checkout";
        br = "branch";
        ci = "commit";
        df = "diff";
        lg = "log --oneline --graph --decorate";
        last = "log -1 HEAD";
      };

      init.defaultBranch = "main";

      color.ui = "auto";
      diff.colorMoved = "default";

      core = {
        editor = "nvim";
        autocrlf = "input";
      };

      pull = {
        rebase = true;
        ff = "only";
      };

      rebase.autoStash = true;

      push = {
        default = "simple";
        followTags = true;
      };

      merge = {
        ff = "only";
        conflictStyle = "zdiff3";
      };

      help.autocorrect = 10;
      gpg.program = "gpg";
    };

    includes = [
      {
        path = profile.privateIncludes.git;
      }
    ];
  };
}
