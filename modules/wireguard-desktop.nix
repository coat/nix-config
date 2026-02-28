{config, ...}: let
  wg = {
    address = "10.29.177.72/32";
    dns = "10.0.0.243";
    peer = {
      publicKey = "XUGQ34tXRHoP9arLWx6gkMisK3j/Mzb5ex8zoz1ePjQ=";
      allowedIPs = "0.0.0.0/0";
      endpoint = "158.173.153.140:1337";
      persistentKeepalive = 25;
    };
  };
in {
  clan.core.vars.generators.wireguard-desktop-vpn = {
    share = true;
    files.wg-desktop-key = {
      secret = true;
      owner = "systemd-network";
      group = "systemd-network";
      mode = "0400";
    };
    prompts.private-key = {
      description = "WireGuard desktop VPN private key";
      type = "hidden";
    };
    script = ''
      priv_key="$(cat "$prompts/private-key" | tr -d '\n ')"
      echo -n "$priv_key" > "$out/wg-desktop-key"
    '';
  };

  networking.wg-quick.interfaces.wg0 = {
    autostart = false;
    address = [wg.address];
    dns = [wg.dns];
    privateKeyFile = config.clan.core.vars.generators.wireguard-desktop-vpn.files.wg-desktop-key.path;
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
