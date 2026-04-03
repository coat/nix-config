{...}: let
  wg = {
    address = "10.237.0.149/32";
    dns = "10.0.0.243";
    peer = {
      publicKey = "lpBPIwqrXhVvgejt67gCC98IY84jP5toK+gbfJ2VuiM=";
      allowedIPs = "0.0.0.0/0";
      endpoint = "173.239.198.129:1337";
      persistentKeepalive = 25;
    };
  };
in {
  clan.core.vars.generators.wireguard-vpn = {
    share = true;
    files.wg-conf.secret = true;
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
      Address = ${wg.address}
      PrivateKey = $priv_key
      DNS = ${wg.dns}
      [Peer]
      PersistentKeepalive = ${toString wg.peer.persistentKeepalive}
      PublicKey = ${wg.peer.publicKey}
      AllowedIPs = ${wg.peer.allowedIPs}
      Endpoint = ${wg.peer.endpoint}
      EOF
    '';
  };
}
