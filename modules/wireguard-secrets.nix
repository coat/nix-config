{
  clan.core.vars.generators.wireguard-vpn = {
    share = true;
    files.wg-conf = {
      secret = true;
    };
    files.wg-key = {
      secret = true;
      owner = "systemd-network";
      group = "systemd-network";
      mode = "0400";
    };
    prompts.private-key = {
      description = "WireGuard VPN private key";
      type = "hidden";
    };
    script = ''
      priv_key="$(cat "$prompts/private-key" | tr -d '\n ')"
      echo -n "$priv_key" > "$out/wg-key"
      cat > "$out/wg-conf" <<EOF
      [Interface]
      Address = 10.17.205.221
      PrivateKey = $priv_key
      DNS = 10.0.0.243
      [Peer]
      PersistentKeepalive = 25
      PublicKey = WbYarp116unGvL3OjsplJSj686LuY2dVIuius3lDAGM=
      AllowedIPs = 0.0.0.0/0
      Endpoint = 212.56.52.56:1337
      EOF
    '';
  };
}
