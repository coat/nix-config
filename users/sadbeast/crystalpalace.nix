{self, inputs, ...}: {
  imports = [
    self.inputs.home-manager.nixosModules.default
  ];
  home-manager.users.sadbeast = {
    imports = [
   inputs.nixvim.homeModules.nixvim
      ./home.nix
    ];
  };
  time.timeZone = "America/Los_Angeles";
}
