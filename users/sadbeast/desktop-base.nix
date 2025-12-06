{nixosConfig, ...}: {
  # Common desktop home-manager configuration
  imports = [
    ./home.nix
    ../features/desktop
    ../features/desktop/games.nix
    ../features/dev.nix
  ];

  programs.librewolf.profiles.sadbeast = {};

  stylix.targets.librewolf.profileNames = ["sadbeast"];

  services.syncthing = {
    enable = true;

    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI

    passwordFile = nixosConfig.clan.core.vars.generators.syncthing.files.password.path;

    settings = {
      devices = {
        "android" = {id = "HRX5BNT-KRGX5X4-MVZNXB3-5RMWIOK-JQZNV3V-Z5FWCLD-2T42CYW-KSWCMQI";};
      };
    };
  };
}
