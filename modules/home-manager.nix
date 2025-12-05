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
    ];
  };
}
