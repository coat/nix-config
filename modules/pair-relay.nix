# Public TCP relay for microvms/pairvm.nix so a peer needs nothing but
# OpenSSH: peer -> cheyenne:2222 -> (zerotier) -> joshua:2222 -> pairvm:22.
# Cheyenne only shuffles bytes; the SSH session terminates in the VM.
{
  lib,
  pkgs,
  ...
}: let
  port = 2222;
  host = "joshua";
  # Zerotier IPs are derived from the node identity, so they're stable even
  # though joshua's home IP isn't. Same public var the controller reads.
  ztIp = lib.trim (builtins.readFile (../vars/shared + "/zerotier-ip-${host}-zerotier/ip/value"));
in {
  systemd.sockets.pair-relay = {
    description = "SSH relay to pairvm on ${host}";
    wantedBy = ["sockets.target"];
    listenStreams = [(toString port)];
  };

  # socket-proxyd splits HOST:PORT on the last colon and doesn't understand
  # [v6]:port, so give the address a name instead of passing it literally.
  networking.hosts.${ztIp} = ["${host}.zt"];

  systemd.services.pair-relay.serviceConfig.ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd ${host}.zt:${toString port}";

  networking.firewall.allowedTCPPorts = [port];
}
