{
  imports = [
    ../features/global.nix
    ../features/nixvim-dev.nix
    ../features/dev.nix
  ];

  home = {
    username = "vscode";
    homeDirectory = "/home/vscode";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "25.11";
  };
}
