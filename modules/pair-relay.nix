# Public front door for microvms/pairvm.nix, all under pair.sadbeast.com
# (the *.sadbeast.com wildcard already points here):
#   SSH:  peer -> cheyenne:2222 -> (zerotier) -> joshua:2222 -> pairvm:22.
#         Cheyenne only shuffles bytes; the SSH session terminates in the VM.
#   HTTPS: pairvm's own ai-beacon dashboard (modules/pair-beacon.nix):
#         cheyenne:443 (TLS) -> joshua:8091 -> pairvm:8090.
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

  services.nginx.virtualHosts."pair.sadbeast.com" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      proxyPass = "http://${host}:8091";
      proxyWebsockets = true;
      recommendedProxySettings = true;
      extraConfig = ''
        # The dashboard is live WebSockets/streams: don't buffer them, and keep
        # idle connections open well past nginx's 60s default.
        proxy_buffering off;
        proxy_read_timeout 3600;
        proxy_send_timeout 3600;
      '';
    };
  };
}
