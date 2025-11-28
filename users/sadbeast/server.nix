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
    users.sadbeast = {
      imports = [
        inputs.nixvim.homeModules.nixvim
        ./home.nix
      ];
    };
  };
  time.timeZone = "America/Los_Angeles";
}
