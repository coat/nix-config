{pkgs, ...}: let
  sshKeys = import ../../modules/ssh-keys.nix;
in {
  users.users.sadbeast = {
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = sshKeys.sadbeast;
    extraGroups = ["docker" "audio"];

    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };
}
