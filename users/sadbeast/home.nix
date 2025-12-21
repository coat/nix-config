{lib, ...}: {
  imports = [
    ../features/global.nix
    ../features/gpg.nix
    ../features/pass.nix
    ../features/ssh.nix
  ];

  home = {
    username = "sadbeast";
    homeDirectory = "/home/sadbeast";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "25.05";
  };

  programs = {
    git.settings.user.name = "Sad Beast";
    git.settings.user.email = lib.mkDefault "sadbeast@sadbeast.com";
  };
}
