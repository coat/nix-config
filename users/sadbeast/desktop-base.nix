{
  # Common desktop home-manager configuration
  imports = [
    ./home.nix
    ../features/desktop
    ../features/desktop/games.nix
    ../features/dev.nix
  ];
}
