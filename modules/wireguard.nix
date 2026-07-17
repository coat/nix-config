{
  config,
  pkgs,
  ...
}: let
  wgConfPath = "/run/pia-wg/wg.conf";
  piaCaCert = ./pia-ca.rsa.4096.crt;

  connectScript = pkgs.writeShellApplication {
    name = "pia-wg-connect";
    runtimeInputs = with pkgs; [curl jq wireguard-tools coreutils bash];
    text = ''
            set -euo pipefail

            PIA_USER=$(cat ${config.clan.core.vars.generators.pia-credentials.files.pia-user.path})
            PIA_PASS=$(cat ${config.clan.core.vars.generators.pia-credentials.files.pia-pass.path})

            echo "Getting PIA auth token..."
            token_resp=$(curl -s --location --request POST \
              'https://www.privateinternetaccess.com/api/client/v2/token' \
              --form "username=$PIA_USER" \
              --form "password=$PIA_PASS")
            token=$(echo "$token_resp" | jq -r '.token')

            if [[ -z "$token" || "$token" == "null" ]]; then
              echo "Failed to get PIA token: $token_resp" >&2
              exit 1
            fi

            echo "Getting server list..."
            all_region_data=$(curl -s 'https://serverlist.piaservers.net/vpninfo/servers/v6' | head -1)

            # Test WireGuard server latency in parallel and pick lowest
            test_server() {
              ip=$1; cn=$2; id=$3
              time=$(LC_NUMERIC=en_US.utf8 curl -o /dev/null -s \
                --connect-timeout 0.5 \
                --write-out "%{time_connect}" \
                "http://$ip:443" 2>/dev/null || true)
              if [[ -n "$time" && "$time" != "0.000000" ]]; then
                echo "$time $ip $cn $id"
              fi
            }
            export -f test_server

            echo "Testing server latency (port-forward-capable regions only)..."
            best=$(echo "$all_region_data" \
              | jq -r '.regions[] | select(.port_forward == true) | .servers.wg[0] | .ip + " " + .cn + " " + .ip' \
              | xargs -P 20 -I{} bash -c 'test_server {}' 2>/dev/null \
              | sort -n | head -1) || true

            if [[ -z "$best" ]]; then
              echo "No server responded within latency threshold" >&2
              exit 1
            fi

            WG_SERVER_IP=$(echo "$best" | cut -d' ' -f2)
            WG_HOSTNAME=$(echo "$best" | cut -d' ' -f3)
            echo "Selected server: $WG_HOSTNAME ($WG_SERVER_IP)"

            # Generate ephemeral WireGuard keypair
            priv_key=$(wg genkey)
            pub_key=$(echo "$priv_key" | wg pubkey)

            echo "Registering with PIA WireGuard API..."
            wg_json=$(curl -s -G \
              --connect-to "$WG_HOSTNAME::$WG_SERVER_IP:" \
              --cacert "${piaCaCert}" \
              --data-urlencode "pt=$token" \
              --data-urlencode "pubkey=$pub_key" \
              "https://$WG_HOSTNAME:1337/addKey")

            if [[ $(echo "$wg_json" | jq -r '.status') != "OK" ]]; then
              echo "PIA API error: $wg_json" >&2
              exit 1
            fi

            peer_ip=$(echo "$wg_json" | jq -r '.peer_ip')
            server_key=$(echo "$wg_json" | jq -r '.server_key')
            server_port=$(echo "$wg_json" | jq -r '.server_port')
            server_vip=$(echo "$wg_json" | jq -r '.server_vip')
            dns=$(echo "$wg_json" | jq -r '.dns_servers[0]')

            mkdir -p /run/pia-wg
            cat > "${wgConfPath}" <<EOF
      [Interface]
      Address = $peer_ip
      PrivateKey = $priv_key
      DNS = $dns

      [Peer]
      PersistentKeepalive = 25
      PublicKey = $server_key
      AllowedIPs = 0.0.0.0/0
      Endpoint = $WG_SERVER_IP:$server_port
      EOF
            chmod 600 "${wgConfPath}"

            # Persist metadata the port-forward service needs: the same token used
            # for addKey, the server hostname/cn for TLS, and both candidate
            # gateways for the getSignature/bindPort API. PIA's own script targets
            # the public server IP (reached off-tunnel via wg-quick's endpoint
            # route exception); this netns has no such exception and routes
            # everything through wg0, so the in-tunnel VIP is the likely target.
            # The port-forward service probes both and uses whichever answers.
            # Drop any port-forward state from a previous connection so a fresh
            # port is requested for this new server.
            cat > /run/pia-wg/pf-meta.env <<EOF
      PF_HOSTNAME=$WG_HOSTNAME
      PF_GATEWAY_VIP=$server_vip
      PF_GATEWAY_PUB=$WG_SERVER_IP
      PIA_TOKEN=$token
      EOF
            chmod 600 /run/pia-wg/pf-meta.env
            rm -f /run/pia-wg/pf-state.env

            echo "WireGuard config written: $WG_HOSTNAME $WG_SERVER_IP -> $peer_ip"
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
        systemctl restart transmission.service
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
      # transmission starts, else the daemon caches the resolution failures and
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
    runtimeInputs = with pkgs; [curl jq coreutils iproute2 iptables transmission_4 bash];
    text = ''
      set -euo pipefail

      META=/run/pia-wg/pf-meta.env
      STATE=/run/pia-wg/pf-state.env
      RPC=192.168.15.1:9091

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

      wait_for_transmission() {
        local _i
        for _i in $(seq 1 30); do
          if ip netns exec wg timeout 5 transmission-remote "$RPC" -si >/dev/null 2>&1; then
            return 0
          fi
          sleep 2
        done
        echo "transmission RPC not reachable at $RPC" >&2
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
        # Point transmission at the forwarded port. peer-port is both the listen
        # port and the port announced to the swarm, so it must equal the forward.
        # Applied live via RPC and re-asserted every run, since nixarr resets
        # settings.json back to the declared peerPort whenever transmission restarts.
        ip netns exec wg timeout 15 transmission-remote "$RPC" -p "$port" >/dev/null
        echo "transmission peer-port set to $port and opened in netns firewall"
      }

      wait_for_transmission

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

  cleanupScript = pkgs.writeShellApplication {
    name = "pia-transmission-cleanup";
    runtimeInputs = with pkgs; [transmission_4 coreutils gawk gnugrep iproute2];
    text = ''
      RPC=192.168.15.1:9091
      REMOVED=0

      # Query each torrent individually: the -l table's Have column ("8.90 GB")
      # splits into two awk fields, so positional parsing of Status is unreliable.
      # Ratio/idle-stopped torrents report "Finished"; "Stopped" is a manual pause.
      while read -r id; do
        info=$(ip netns exec wg transmission-remote "$RPC" -t "$id" -i 2>/dev/null)
        if grep -q "Percent Done: 100%" <<<"$info" \
          && grep -qE "State: (Stopped|Finished)" <<<"$info"; then
          ip netns exec wg transmission-remote "$RPC" -t "$id" -r >/dev/null 2>&1 && REMOVED=$((REMOVED+1))
        fi
      done < <(ip netns exec wg transmission-remote "$RPC" -l 2>/dev/null | awk 'NR>1 && !/^Sum:/ {gsub(/\*$/, "", $1); print $1}')

      echo "Cleanup: removed $REMOVED stopped/finished completed torrents (data kept)"
    '';
  };
in {
  clan.core.vars.generators.pia-credentials = {
    share = true;
    files.pia-user.secret = true;
    files.pia-pass.secret = true;
    prompts.pia-user = {
      description = "PIA username (p#######)";
    };
    prompts.pia-pass = {
      description = "PIA password";
      type = "hidden";
    };
    script = ''
      cp "$prompts/pia-user" "$out/pia-user"
      cp "$prompts/pia-pass" "$out/pia-pass"
    '';
  };

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
  # Ordered before transmission so the daemon never starts against broken DNS.
  systemd.services.pia-dns-route = {
    description = "Pin PIA in-tunnel DNS route inside the wg netns";
    after = ["wg.service"];
    before = ["transmission.service"];
    requiredBy = ["transmission.service"];
    partOf = ["wg.service"];
    wantedBy = ["wg.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${dnsRouteScript}/bin/pia-dns-route";
    };
  };

  # Request and maintain a PIA-forwarded port so transmission can accept incoming
  # peer connections (crucial for scarcely-seeded torrents). Runs after the netns
  # and transmission are up, and re-runs whenever wg restarts (new server -> new
  # port). PIA requires the binding to be refreshed at least every 15 minutes.
  systemd.services.pia-port-forward = {
    description = "PIA WireGuard port forwarding for transmission";
    after = ["wg.service" "transmission.service"];
    wants = ["transmission.service"];
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

  systemd.services.pia-transmission-cleanup = {
    description = "Remove idle completed transmission torrents";
    after = ["wg.service" "transmission.service"];
    wants = ["transmission.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${cleanupScript}/bin/pia-transmission-cleanup";
    };
  };

  systemd.timers.pia-transmission-cleanup = {
    description = "Weekly cleanup of idle completed torrents";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      Unit = "pia-transmission-cleanup.service";
    };
  };
}
