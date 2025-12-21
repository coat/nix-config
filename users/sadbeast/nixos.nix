{pkgs, ...}: let
  sshKeys = import ../../modules/ssh-keys.nix;
in
  import ../../modules/user-account.nix {
    inherit pkgs;
    name = "sadbeast";
    sshKeys = sshKeys.sadbeast;
    extraGroups = ["docker" "audio"];
    enableSubIds = true;
  }
