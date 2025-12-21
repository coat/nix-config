{
  inputs,
  lib,
  config,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  sops = {
    age = {
      #keyFile = "/persistent/var/lib/sops-nix/keys.txt";
      keyFile = "/var/lib/sops-nix/keys.txt";
      sshKeyPaths = [];
    };
    gnupg.sshKeyPaths = [];
  };
}
