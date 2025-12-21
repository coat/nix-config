{
  imports = [
    ../../modules/desktop-nixos-base.nix
  ];

  home-manager.users.kent.imports = [./falken.nix];
}
