{
  inputs,
  config,
  ...
}: {
  imports = [
    ./home.nix
    ../features/desktop
    ../features/desktop/games.nix
    ../features/dev.nix
  ];

  programs.bluetuith.enable = true;
}
