{inputs, config, ...}: {
  imports = [
    # inputs.home-manager.nixosModules.default
    ./home.nix
    ../features/desktop
    ../features/desktop/games.nix
    ../features/dev.nix
  ];

  programs.bluetuith.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  # home.stateVersion = "25.05";
}
