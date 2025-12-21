{
  imports = [
    ../../modules/home-manager.nix
    ../../modules/home-manager-stylix.nix
  ];

  home-manager.users.sadbeast.imports = [./home.nix];
}
