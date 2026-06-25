{config, inputs, lib, profile, ...}: {
  config = lib.mkIf config.solomon.home.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      extraSpecialArgs = {
        inherit inputs profile;
      };

      users.${profile.username} = import ../home.nix;
    };
  };
}
