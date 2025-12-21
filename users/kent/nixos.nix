{pkgs, ...}: let
  sshKeys = import ../../modules/ssh-keys.nix;
in {
  users.users.kent = {
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = sshKeys.kent;
  };
}
