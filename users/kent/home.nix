let
  identity = import ./identity.nix;
in {
  imports = [
    (import ../common/home-base.nix {
      inherit (identity) username realName email;
      extraImports = [
        ../features/dev.nix
        ../features/desktop/dev.nix
      ];
    })
  ];
}
