{
  self,
  inputs,
  ...
}: {
  imports = [
    self.inputs.home-manager.nixosModules.default
  ];
  home-manager.users.sadbeast = {
    imports = [
      inputs.nixvim.homeModules.nixvim
      ./home.nix
      ../features/desktop
      ../features/desktop/games.nix
      ../features/dev.nix
    ];

    programs.bluetuith.enable = true;
  };
  time.timeZone = "America/Los_Angeles";
}
