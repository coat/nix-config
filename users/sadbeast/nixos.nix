# System account. Groups and the password come from the clan `users`
# instance in clan.nix.
{
  config,
  pkgs,
  ...
}: let
  sshKeys = import ../../lib/ssh-keys.nix;
in {
  imports = [../../modules/ai-beacon-token.nix];

  # Report this machine's Claude Code / OpenCode sessions to the dashboard on
  # crystalpalace (modules/ai-beacon.nix). By hostname rather than
  # ai-beacon.local: that is mDNS on the home LAN only, while the hostname
  # resolves over ZeroTier everywhere (modules/zerotier-hosts.nix) and to
  # itself on crystalpalace.
  clan.core.vars.generators.ai-beacon-token.files.env.owner = "sadbeast";
  home-manager.users.sadbeast.ai-beacon = {
    url = "http://crystalpalace:8090";
    tokenEnvFile = config.clan.core.vars.generators.ai-beacon-token.files.env.path;
  };

  # Shell history and agent threads, synced through crystalpalace
  # (modules/atuin-server.nix), by hostname for the same reason.
  home-manager.users.sadbeast.atuin = {
    enable = true;
    syncAddress = "http://crystalpalace:8888";
  };

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
