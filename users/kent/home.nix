{
  imports = [
    (import ../common/home-base.nix {
      username = "kent";
      realName = "Kent Smith";
      email = "kent.smith@andros.co";
      extraImports = [
        ../features/dev.nix
        ../features/desktop/dev.nix
      ];
    })
  ];
}
