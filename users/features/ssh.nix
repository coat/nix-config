{
  lib,
  pkgs,
  ...
}: let
  # pairvm's sshd host key lives in the VM's persistent /var volume
  # (modules/microvm-base.nix). Pinned here so herdr's strict host-key
  # checking works on a fresh host without an interactive first ssh, and
  # so the same key is trusted via joshua.local, the cheyenne relay or the
  # bridge IP.
  pairvmKnownHosts =
    pkgs.writeText "pairvm-known-hosts"
    "pairvm ${builtins.readFile ../../lib/pairvm-host-key.pub}";

  # Home machines reached over mDNS.
  lanHosts = lib.genAttrs ["crystalpalace" "joshua" "wopr"] (host: {
    user = "sadbeast";
    hostname = "${host}.local";
  });
in {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings =
      lanHosts
      // {
        "*" = {
          forwardAgent = true;
        };

        "cheyenne" = {
          user = "sadbeast";
          hostname = "cheyenne.sadbeast.com";
        };

        # Through the host-side proxy from microvms/pairvm.nix (sshProxyPort);
        # works from joshua itself as well as from any other LAN host.
        "pairvm" = {
          user = "pair";
          hostname = "joshua.local";
          port = 2222;
          HostKeyAlias = "pairvm";
          UserKnownHostsFile = "~/.ssh/known_hosts ${pairvmKnownHosts}";
        };
      };
  };
}
