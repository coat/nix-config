# Builds a script that logs into PIA, picks the lowest-latency WireGuard
# server, registers an ephemeral key and writes a wg-quick config to
# `wgConfPath`. Shell variables available to `postConnect`: token,
# WG_HOSTNAME, WG_SERVER_IP, peer_ip, server_key, server_port, server_vip, dns.
{
  pkgs,
  config,
  name,
  wgConfPath,
  # Only consider regions that support port forwarding.
  portForwardOnly ? false,
  postConnect ? "",
}: let
  creds = config.clan.core.vars.generators.pia-credentials.files;
  regionFilter =
    if portForwardOnly
    then ".regions[] | select(.port_forward == true)"
    else ".regions[]";
in
  pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [curl jq wireguard-tools coreutils bash];
    text = ''
            PIA_USER=$(cat ${creds.pia-user.path})
            PIA_PASS=$(cat ${creds.pia-pass.path})

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
              | jq -r '${regionFilter} | .servers.wg[0] | .ip + " " + .cn + " " + .ip' \
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
              --cacert "${./ca.rsa.4096.crt}" \
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
            # shellcheck disable=SC2034 # for postConnect
            server_vip=$(echo "$wg_json" | jq -r '.server_vip')
            dns=$(echo "$wg_json" | jq -r '.dns_servers[0]')

            mkdir -p "$(dirname "${wgConfPath}")"
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

            ${postConnect}
    '';
  }
