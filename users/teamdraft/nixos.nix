{pkgs, ...}: let
  sshKeys = import ../../lib/ssh-keys.nix;
in
  import ../../modules/user-account.nix {
    inherit pkgs;
    name = "teamdraft";
    sshKeys = sshKeys.sadbeast;
    extraGroups = ["docker"];
    enableSubIds = false;
  }
