{pkgs, ...}: {
  home.packages = with pkgs; [
    ########################################
    # Basic CLI tools
    ########################################

    curl
    wget
    zip
    unzip
    p7zip
    unrar
    htop
    less
    gnugrep
    ffmpeg
    typst
    tinymist

    ########################################
    # Shell / CLI extras
    ########################################
    lsd

    ########################################
    # Privacy / networking helpers
    ########################################

    torsocks
    openconnect
    openssh
    networkmanagerapplet
    networkmanager-openconnect
  ];
}
