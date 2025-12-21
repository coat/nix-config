{lib, ...}: {
  imports = [
    ../features/global.nix
  ];

  home = {
    username = "sadbeast";
    homeDirectory = "/home/sadbeast";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "25.05";
  };

  programs.git.settings.user.email = lib.mkDefault "sadbeast@sadbeast.com";
}
