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

  # Targets are aliases from features/ssh.nix; the current host is skipped.
  herdr.machines = ["cheyenne" "crystalpalace" "joshua" "wopr" "pairvm"];
}
