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
      Address = 10.20.155.53
      PrivateKey = $priv_key
      DNS = 10.0.0.243
      [Peer]
      PersistentKeepalive = 25
      PublicKey = 5u3eMHBFKLCzKcezy/Xd/F7EqNP75Ixw0ud9hlKYkjg=
      AllowedIPs = 0.0.0.0/0
      Endpoint = 149.22.95.149:1337
      EOF
    '';
  };
}
