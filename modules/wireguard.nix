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

      echo "Testing server latency..."
      best=$(echo "$all_region_data" \
        | jq -r '.regions[].servers.wg[0] | .ip + " " + .cn + " " + .ip' \
        | xargs -P 20 -I{} bash -c 'test_server {}' 2>/dev/null \
        | sort -n | head -1)

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

      echo "WireGuard config written: $WG_HOSTNAME $WG_SERVER_IP -> $peer_ip"
    '';
  };

  watchdogScript = pkgs.writeShellApplication {
    name = "pia-wg-watchdog";
    runtimeInputs = with pkgs; [iputils iproute2 systemd];
    text = ''
      if ! ip netns exec wg ping -c1 -W3 8.8.8.8 > /dev/null 2>&1; then
        echo "VPN health check failed, reconnecting..."
        systemctl restart pia-wg-connect.service
      else
        echo "VPN health check OK"
      fi
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
}
