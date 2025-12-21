{inputs, ...}: {
  imports = [./desktop-nixos-base.nix];

  home-manager.users.sadbeast = {
    imports = [
      inputs.nixvim.homeModules.nixvim
      ./joshua.nix
    ];
  };
}
