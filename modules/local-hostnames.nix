{
  lib,
  pkgs,
  ...
}: let
  # Friendly .local name -> upstream. Add a service = add one line.
  proxies = {
    sonarr = "http://127.0.0.1:8989";
    radarr = "http://127.0.0.1:7878";
    prowlarr = "http://127.0.0.1:9696";
    jellyfin = "http://127.0.0.1:8096";
    seerr = "http://127.0.0.1:5055";
    transmission = "http://192.168.15.1:9091"; # RPC lives in the wg netns
    dispatcharr = "http://127.0.0.1:9191";
    romm = "http://127.0.0.1:8080";
    grafana = "http://127.0.0.1:3010";
  };

  lanInterface = "enp1s0";

  publishAlias = pkgs.writeShellApplication {
    name = "avahi-publish-alias";
    runtimeInputs = with pkgs; [avahi iproute2 jq];
    text = ''
      addr=$(ip -j -4 addr show ${lanInterface} | jq -r '.[0].addr_info[0].local // empty')
      if [ -z "$addr" ]; then
        echo "no IPv4 address on ${lanInterface} yet" >&2
        exit 1
      fi
      exec avahi-publish -a -R "$1" "$addr"
    '';
  };
in {
  # avahi-daemon can't publish extra A records itself; run one publisher per alias.
  systemd.services = lib.mapAttrs' (name: _:
    lib.nameValuePair "avahi-alias-${name}" {
      description = "mDNS alias ${name}.local";
      after = ["network-online.target" "avahi-daemon.service"];
      wants = ["network-online.target"];
      requires = ["avahi-daemon.service"];
      partOf = ["avahi-daemon.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${publishAlias}/bin/avahi-publish-alias ${name}.local";
        Restart = "always";
        RestartSec = 5;
        DynamicUser = true;
      };
    })
  proxies;

  services.nginx = {
    enable = true; # already on via nixarr's transmission vhost; harmless
    virtualHosts = lib.mapAttrs' (name: upstream:
      lib.nameValuePair "${name}.local" {
        locations."/" = {
          proxyPass = upstream;
          proxyWebsockets = true; # SignalR/*arr, jellyfin, grafana; harmless elsewhere
          recommendedProxySettings = true;
        };
      })
    proxies;
  };

  networking.firewall.allowedTCPPorts = [80];
}
