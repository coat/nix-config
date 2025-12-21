{
  imports = [
    ../../modules/home-manager.nix
  ];

  programs.dconf.enable = true;

  home-manager.users.kent.imports = [./falken.nix];
}
