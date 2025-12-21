{
  imports = [./desktop-nixos-base.nix];

  home-manager.users.sadbeast.imports = [./wopr.nix];
}
