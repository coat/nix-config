{pkgs, ...}: let
  sshKeys = import ../../lib/ssh-keys.nix;
in
  import ../../modules/user-account.nix {
    inherit pkgs;
    name = "sadbeast";
    sshKeys = sshKeys.sadbeast;
    extraGroups = ["docker" "audio" "input"];
    enableSubIds = true;
  }
