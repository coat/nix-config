{pkgs, ...}: let
  sshKeys = import ../../modules/ssh-keys.nix;
in
  import ../../modules/user-account.nix {
    inherit pkgs;
    name = "kent";
    sshKeys = sshKeys.kent;
  }
