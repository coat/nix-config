# PIA WireGuard tunnel for nixarr's `wg` network namespace (qBittorrent),
# plus port forwarding, DNS pinning and a watchdog.
{
  config,
  pkgs,
  ...
}: let
  wgConfPath = "/run/pia-wg/wg.conf";
  piaCaCert = ./pia/ca.rsa.4096.crt;

  connectScript = import ./pia/connect-script.nix {
    inherit pkgs config wgConfPath;
    name = "pia-wg-connect";
    portForwardOnly = true;
    # Persist metadata the port-forward service needs: the same token used
    # for addKey, the server hostname/cn for TLS, and both candidate
    # gateways for the getSignature/bindPort API. PIA's own script targets
    # the public server IP (reached off-tunnel via wg-quick's endpoint
    # route exception); this netns has no such exception and routes
    # everything through wg0, so the in-tunnel VIP is the likely target.
    # The port-forward service probes both and uses whichever answers.
    # Drop any port-forward state from a previous connection so a fresh
    # port is requested for this new server.
    postConnect = ''
      cat > /run/pia-wg/pf-meta.env <<EOF
      PF_HOSTNAME=$WG_HOSTNAME
      PF_GATEWAY_VIP=$server_vip
      PF_GATEWAY_PUB=$WG_SERVER_IP
      PIA_TOKEN=$token
      EOF
      chmod 600 /run/pia-wg/pf-meta.env
      rm -f /run/pia-wg/pf-state.env
    '';
  };

  watchdogScript = pkgs.writeShellApplication {
    name = "pia-wg-watchdog";
    runtimeInputs = with pkgs; [iputils iproute2 systemd];
    text = ''
      fail=0
      for attempt in 1 2 3; do
        if ip netns exec wg ping -c1 -W3 8.8.8.8 > /dev/null 2>&1; then
          fail=0
          break
        fi
        fail=$attempt
        sleep 5
      done
      if [ "$fail" -ne 0 ]; then
        echo "VPN health check failed after 3 attempts, reconnecting..."
        systemctl restart pia-wg-connect.service
        systemctl restart wg.service
        systemctl restart qbittorrent.service
      else
        echo "VPN health check OK"
      fi
    '';
  };

  dnsRouteScript = pkgs.writeShellApplication {
    name = "pia-dns-route";
    runtimeInputs = with pkgs; [iproute2 gnugrep coreutils];
    text = ''
      set -euo pipefail

      # PIA pushes an in-tunnel DNS resolver (typically 10.0.0.243). nixarr routes
      # the private ranges through the host veth so the netns can reach the LAN and
      # serve the RPC, but that broad 10.0.0.0/8 route shadows the PIA DNS address
      # and black-holes name resolution to the LAN. Pin a more-specific /32 back
      # through the tunnel so DNS works inside the netns. This must land before
      # qbittorrent starts, else the daemon caches the resolution failures and
      # never recovers without a restart.
      for _i in $(seq 1 30); do
        [[ -f ${wgConfPath} ]] && ip netns exec wg ip link show wg0 >/dev/null 2>&1 && break
        sleep 1
      done

      dns=$(grep -oP '^DNS\s*=\s*\K[0-9.]+' ${wgConfPath} | head -1)
      if [[ -z "''${dns:-}" ]]; then
        echo "No DNS server found in ${wgConfPath}" >&2
        exit 1
      fi

      ip netns exec wg ip route replace "$dns/32" dev wg0
      echo "Pinned PIA DNS $dns via wg0 in netns"
    '';
  };

  portForwardScript = pkgs.writeShellApplication {
    name = "pia-port-forward";
    runtimeInputs = with pkgs; [curl jq coreutils iproute2 iptables bash];
    text = ''
      set -euo pipefail

      META=/run/pia-wg/pf-meta.env
      STATE=/run/pia-wg/pf-state.env
      QBT_API=http://192.168.15.1:8085/api/v2

      if [[ ! -f "$META" ]]; then
        echo "No PIA metadata at $META (VPN not connected yet?)" >&2
        exit 1
      fi
      # shellcheck disable=SC1090
      source "$META" # PF_HOSTNAME, PF_GATEWAY_VIP, PF_GATEWAY_PUB, PIA_TOKEN

      pia_curl() {
        # Must run inside the wg netns so the request traverses the tunnel to the
        # gateway. TLS is validated against the server cn via --connect-to while
        # dialing the gateway IP directly.
        local gw=$1
        shift
        ip netns exec wg curl -s -m 10 \
          --connect-to "$PF_HOSTNAME::$gw:" \
          --cacert "${piaCaCert}" "$@"
      }

      get_signature() {
        local gw resp payload signature port
        # Probe both candidate gateways; keep the one the PF API answers on.
        for gw in "$PF_GATEWAY_VIP" "$PF_GATEWAY_PUB"; do
          [[ -n "$gw" && "$gw" != "null" ]] || continue
          resp=$(pia_curl "$gw" -G --data-urlencode "token=$PIA_TOKEN" \
            "https://$PF_HOSTNAME:19999/getSignature") || true
          [[ $(jq -r '.status' <<<"$resp" 2>/dev/null) == "OK" ]] || continue
          payload=$(jq -r '.payload' <<<"$resp")
          signature=$(jq -r '.signature' <<<"$resp")
          port=$(base64 -d <<<"$payload" | jq -r '.port')
          {
            echo "PF_GATEWAY=$gw"
            echo "PF_PORT=$port"
            echo "PF_PAYLOAD=$payload"
            echo "PF_SIGNATURE=$signature"
          } >"$STATE"
          chmod 600 "$STATE"
          echo "Obtained forwarded port $port from $PF_HOSTNAME via gateway $gw"
          return 0
        done
        echo "getSignature failed on all gateways: $resp" >&2
        return 1
      }

      bind_port() {
        # shellcheck disable=SC1090
        source "$STATE" # PF_GATEWAY, PF_PORT, PF_PAYLOAD, PF_SIGNATURE
        local resp
        resp=$(pia_curl "$PF_GATEWAY" -G \
          --data-urlencode "payload=$PF_PAYLOAD" \
          --data-urlencode "signature=$PF_SIGNATURE" \
          "https://$PF_HOSTNAME:19999/bindPort")
        if [[ $(jq -r '.status' <<<"$resp") != "OK" ]]; then
          echo "bindPort failed: $resp" >&2
          return 1
        fi
        echo "bindPort OK for port $PF_PORT"
      }

      wait_for_qbittorrent() {
        local _i
        for _i in $(seq 1 30); do
          if ip netns exec wg curl -s -m 5 "$QBT_API/app/version" >/dev/null 2>&1; then
            return 0
          fi
          sleep 2
        done
        echo "qBittorrent WebUI not reachable at $QBT_API" >&2
        return 1
      }

      apply_port() {
        local port=$1 proto
        # Open the forwarded port in the netns firewall (idempotent). Incoming
        # peers arrive on wg0 with this dport, and nixarr's default INPUT policy
        # drops anything not explicitly allowed.
        for proto in tcp udp; do
          if ! ip netns exec wg iptables -C INPUT -i wg0 -p "$proto" --dport "$port" -j ACCEPT 2>/dev/null; then
            ip netns exec wg iptables -I INPUT -i wg0 -p "$proto" --dport "$port" -j ACCEPT
          fi
        done
        # Point qBittorrent at the forwarded port. listen_port is both the listen
        # port and the port announced to the swarm, so it must equal the forward.
        # Applied live via the WebUI API and re-asserted every run, since nixarr
        # regenerates qBittorrent.conf from the declared peerPort on restart.
        # The request originates from 192.168.15.x, which the WebUI's
        # AuthSubnetWhitelist lets through without a login.
        ip netns exec wg curl -s -m 15 -X POST "$QBT_API/app/setPreferences" \
          --data-urlencode "json={\"listen_port\": $port}" >/dev/null
        echo "qBittorrent listen_port set to $port and opened in netns firewall"
      }

      wait_for_qbittorrent

      # If we already hold a port, keep it alive by re-binding and re-asserting it.
      # If the re-bind fails (the forward expired, or the VPN reconnected to a new
      # server), request a fresh port.
      if [[ -f "$STATE" ]] && bind_port; then
        # shellcheck disable=SC1090
        source "$STATE"
        apply_port "$PF_PORT"
      else
        get_signature
        # shellcheck disable=SC1090
        source "$STATE"
        apply_port "$PF_PORT"
        bind_port
      fi
    '';
  };
in {
  imports = [./pia/credentials.nix];

  systemd.services.pia-wg-connect = {
    description = "PIA WireGuard VPN connection setup";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    before = ["wg.service"];
    wantedBy = ["wg.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${connectScript}/bin/pia-wg-connect";
      RuntimeDirectory = "pia-wg";
      RuntimeDirectoryMode = "0700";
    };
  };

  # Make wg.service depend on and restart with pia-wg-connect
  systemd.services.wg = {
    after = ["pia-wg-connect.service"];
    requires = ["pia-wg-connect.service"];
    partOf = ["pia-wg-connect.service"];
  };

  systemd.services.pia-wg-watchdog = {
    description = "PIA WireGuard VPN connectivity watchdog";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${watchdogScript}/bin/pia-wg-watchdog";
    };
  };

  systemd.timers.pia-wg-watchdog = {
    description = "PIA WireGuard VPN watchdog timer";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "5min";
      Unit = "pia-wg-watchdog.service";
    };
  };

  # Pin PIA's in-tunnel DNS resolver back through the tunnel. Without this the
  # netns's broad 10.0.0.0/8-via-veth route shadows the DNS address, breaking all
  # name resolution (trackers, DHT) inside the netns and stalling every torrent.
  # Ordered before qbittorrent so the daemon never starts against broken DNS.
  systemd.services.pia-dns-route = {
    description = "Pin PIA in-tunnel DNS route inside the wg netns";
    after = ["wg.service"];
    before = ["qbittorrent.service"];
    requiredBy = ["qbittorrent.service"];
    partOf = ["wg.service"];
    wantedBy = ["wg.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${dnsRouteScript}/bin/pia-dns-route";
    };
  };

  # Request and maintain a PIA-forwarded port so qBittorrent can accept incoming
  # peer connections (crucial for scarcely-seeded torrents). Runs after the netns
  # and qbittorrent are up, and re-runs whenever wg restarts (new server -> new
  # port). PIA requires the binding to be refreshed at least every 15 minutes.
  systemd.services.pia-port-forward = {
    description = "PIA WireGuard port forwarding for qBittorrent";
    after = ["wg.service" "qbittorrent.service"];
    wants = ["qbittorrent.service"];
    partOf = ["wg.service"];
    wantedBy = ["wg.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${portForwardScript}/bin/pia-port-forward";
    };
  };

  systemd.timers.pia-port-forward = {
    description = "Refresh PIA port forwarding binding";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "3min";
      OnUnitActiveSec = "14min";
      Unit = "pia-port-forward.service";
    };
  };
}
