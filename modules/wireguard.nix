{config, ...}: let
  wg = {
    address = "10.30.153.91";
    dns = "10.0.0.243";
    peer = {
      publicKey = "sy1NqWlIaEIfiR2txshRIANdZ7rKBlxiZNaJqQgzrmY=";
      allowedIPs = "0.0.0.0/0";
      endpoint = "158.173.153.141:1337";
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

  networking.wg-quick.interfaces.wg0 = {
    autostart = false;
    address = ["${wg.address}/32"];
    dns = [wg.dns];
    privateKeyFile = config.clan.core.vars.generators.wireguard-vpn.files.wg-key.path;
    peers = [
      {
        publicKey = wg.peer.publicKey;
        allowedIPs = [wg.peer.allowedIPs];
        endpoint = wg.peer.endpoint;
        persistentKeepalive = wg.peer.persistentKeepalive;
      }
    ];
  };
}
