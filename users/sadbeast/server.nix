{
  self,
  inputs,
  outputs,
  ...
}: {
  imports = [
    self.inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs outputs;};

    sharedModules = [
      inputs.nixvim.homeModules.nixvim
      inputs.nix-index-database.homeModules.nix-index
      inputs.stylix.homeModules.stylix
      ../../modules/stylix.nix
      {
        stylix = {
          autoEnable = false;

          targets.btop.enable = true;
          targets.fzf.enable = true;
          targets.nixvim.enable = true;
          targets.starship.enable = true;
          targets.tmux.enable = true;
        };
      }
    ];

    users.sadbeast.imports = [./home.nix];
  };
  time.timeZone = "America/Los_Angeles";
}
