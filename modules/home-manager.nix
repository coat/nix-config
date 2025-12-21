{
  self,
  inputs,
  outputs,
  config,
  ...
}: {
  imports = [
    self.inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs outputs;
      nixosConfig = config;
    };

    sharedModules = [
      inputs.nixvim.homeModules.nixvim
      inputs.nix-index-database.homeModules.nix-index
    ];
  };
}
