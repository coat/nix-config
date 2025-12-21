{
  self,
  inputs,
  outputs,
  ...
}: {
  imports = [
    self.inputs.home-manager.nixosModules.default
  ];

  programs.dconf.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs outputs;};
    users.sadbeast = {
      imports = [
        inputs.nixvim.homeModules.nixvim
        ./joshua.nix
      ];
    };
  };
  time.timeZone = "America/Los_Angeles";
}
