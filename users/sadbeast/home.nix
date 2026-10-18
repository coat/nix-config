{
  config,
  lib,
  ...
}: {
  imports = [
    ../common/home-base.nix
    ../features/gpg.nix
    ../features/pass.nix
    ../features/ssh.nix
  ];

  me = {
    username = "sadbeast";
    realName = "Sad Beast";
    email = "sadbeast@sadbeast.com";
  };

  # Every host alias from features/ssh.nix; the current host is skipped.
  herdr.machines = lib.remove "*" (builtins.attrNames config.programs.ssh.settings);
}
