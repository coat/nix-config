{lib, ...}: {
  imports = [
    ../features/desktop
    ../features/desktop/dev.nix
    ../features/dev.nix
    ../features/global.nix
  ];

  programs.librewolf.profiles.kent = {};

  stylix.targets.librewolf.profileNames = ["kent"];

  home = {
    username = "kent";
    homeDirectory = "/home/kent";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "25.11";
  };

  programs = {
    git.settings.user.name = "Kent Smith";
    git.settings.user.email = lib.mkDefault "sadbeast@sadbeast.com";
  };
}
