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

  xdg.userDirs = let
    homeDir = config.home.homeDirectory;
  in {
    enable = true;
    createDirectories = false;

    desktop = "${homeDir}";
    documents = "${homeDir}/docs";
    download = "${homeDir}/downloads";
    pictures = "${homeDir}/pics";
  };
}
