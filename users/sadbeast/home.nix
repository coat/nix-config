{
  imports = [
    (import ../common/home-base.nix {
      username = "sadbeast";
      realName = "Sad Beast";
      email = "sadbeast@sadbeast.com";
      extraImports = [
        ../features/gpg.nix
        ../features/pass.nix
        ../features/ssh.nix
      ];
    })
  ];
}
