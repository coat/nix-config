# System account. Groups and the password come from the clan `users`
# instance in clan.nix.
{pkgs, ...}: let
  sshKeys = import ../../lib/ssh-keys.nix;
  identity = import ./identity.nix;
in {
  users.users.${identity.username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = sshKeys.kent;
  };
}
