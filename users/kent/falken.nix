{lib, ...}: {
  imports = [
    ./home.nix
    ../features/desktop
  ];

  home.stateVersion = lib.mkForce "25.11";

  programs.librewolf.profiles.kent = {};
  stylix.targets.librewolf.profileNames = ["kent"];
}
