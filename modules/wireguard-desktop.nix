{
  config,
  pkgs,
  ...
}: let
  wgConfPath = "/run/pia-wg-desktop/wg0.conf";
  piaCaCert = ./pia-ca.rsa.4096.crt;

  connectScript = pkgs.writeShellApplication {
    name = "pia-wg-desktop-connect";
    runtimeInputs = with pkgs; [curl jq wireguard-tools coreutils bash];
    text = ''
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
      wg-quick up "${wgConfPath}"
    '';
  };

  disconnectScript = pkgs.writeShellApplication {
    name = "pia-wg-desktop-disconnect";
    runtimeInputs = with pkgs; [wireguard-tools];
    text = ''
      if [[ -f "${wgConfPath}" ]]; then
        wg-quick down "${wgConfPath}" || true
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

  systemd.services.pia-wg-desktop = {
    description = "PIA WireGuard Desktop VPN";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${connectScript}/bin/pia-wg-desktop-connect";
      ExecStop = "${disconnectScript}/bin/pia-wg-desktop-disconnect";
      RuntimeDirectory = "pia-wg-desktop";
      RuntimeDirectoryMode = "0700";
    };
  };
}
