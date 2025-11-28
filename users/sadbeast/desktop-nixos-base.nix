{
  self,
  inputs,
  outputs,
  ...
}: {
  # Common desktop NixOS configuration with home-manager
  imports = [
    self.inputs.home-manager.nixosModules.default
  ];

  programs.dconf.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs outputs;};
  };

  time.timeZone = "America/Los_Angeles";
}
