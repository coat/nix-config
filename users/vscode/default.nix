{
  imports = [
    ../common/home-base.nix
    ../features/dev.nix
  ];

  me.username = "vscode";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
