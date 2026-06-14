{
  imports = [
    ../features/desktop
    ../features/desktop/i3.nix
  ];

  programs.librewolf.profiles.kent = {};
  stylix.targets.librewolf.profileNames = ["kent"];
}
