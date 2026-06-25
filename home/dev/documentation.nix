{pkgs, ...}: {
  ########################################
  # Documentation / man pages
  ########################################
  #
  # C / POSIX / Linux documentation only.
  #
  # Home Manager module.
  #
  # This installs documentation sets only:
  #
  #   man 2 open
  #   man 3 fopen
  #   man 3posix fopen
  #   man 7posix pthread.h
  #   info libc
  #
  # No compilers, debuggers, tracing tools, or C++ docs.
  #
  # Note:
  #
  #   documentation.man.generateCaches = false;
  #
  # is a NixOS system option, not a Home Manager option.
  # Put that in configuration.nix if rebuilds are slow from man-cache.

  home.packages = with pkgs; [
    ########################################
    # C / POSIX / Linux documentation sets
    ########################################

    # Linux syscall and C library man pages.
    man-pages

    # POSIX command/libc/header man pages.
    man-pages-posix

    # GNU C Library info documentation.
    glibcInfo

    ########################################
    # Documentation readers
    ########################################

    # Provides `man` / `mandb`.
    #
    # If your system config already provides man-db, you can remove this.
    man-db

    # Provides `info`, needed for:
    #
    #   info libc
    #
    texinfo

    # Pager used by man/info.
    less
  ];
}
