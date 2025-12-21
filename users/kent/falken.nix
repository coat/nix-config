{
  imports = [
    (import ../common/home-base.nix {
      username = "kent";
      realName = "Kent Smith";
      email = "sadbeast@sadbeast.com";
      stateVersion = "25.11";
      extraImports = [
        ../features/desktop
        ../features/desktop/dev.nix
        ../features/dev.nix
      ];
    })
  ];

  programs.librewolf.profiles.kent = {};
  stylix.targets.librewolf.profileNames = ["kent"];
}
