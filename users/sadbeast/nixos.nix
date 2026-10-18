# System account. Groups and the password come from the clan `users`
# instance in clan.nix.
{pkgs, ...}: let
  sshKeys = import ../../lib/ssh-keys.nix;
in {
  users.users.sadbeast = {
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = sshKeys.sadbeast;
    # Rootless podman/docker.
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
