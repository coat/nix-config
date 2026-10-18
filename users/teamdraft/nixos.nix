# Deploy account for teamdraft.party on cheyenne (imported by its
# configuration.nix, not a clan user).
{pkgs, ...}: let
  sshKeys = import ../../lib/ssh-keys.nix;
in {
  users.users.teamdraft = {
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = sshKeys.sadbeast;
    extraGroups = ["docker"];
  };
}
