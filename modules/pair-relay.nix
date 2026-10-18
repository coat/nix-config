# Public TCP relay for microvms/pairvm.nix so a peer needs nothing but
# OpenSSH: peer -> cheyenne:2222 -> (zerotier) -> joshua:2222 -> pairvm:22.
# Cheyenne only shuffles bytes; the SSH session terminates in the VM.
{pkgs, ...}: let
  port = 2222;
  # Resolves to joshua's ZeroTier IP via modules/zerotier-hosts.nix. Passing a
  # name also sidesteps socket-proxyd not understanding [v6]:port literals.
  host = "joshua";
in {
  systemd.sockets.pair-relay = {
    description = "SSH relay to pairvm on ${host}";
    wantedBy = ["sockets.target"];
    listenStreams = [(toString port)];
  };

  systemd.services.pair-relay.serviceConfig.ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd ${host}:${toString port}";

  networking.firewall.allowedTCPPorts = [port];
}
