{
  imports = [
    ../../modules/home-manager-stylix.nix
  ];

  users.users.sadbeast.extraGroups = ["video" "audio"];
}
