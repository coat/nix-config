{
  imports = [
    ./desktop-base.nix
    ../features/desktop/games.nix
  ];

  programs.bluetuith.enable = true;
}
