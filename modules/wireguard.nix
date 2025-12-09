{config, ...}: {
  imports = [./wireguard-secrets.nix];

  networking.wg-quick.interfaces = {
    wg0 = {
      autostart = false;
      address = ["10.17.205.221/32"];
      dns = ["10.0.0.243"];
      privateKeyFile = config.clan.core.vars.generators.wireguard-vpn.files.wg-key.path;

      peers = [
        {
          publicKey = "WbYarp116unGvL3OjsplJSj686LuY2dVIuius3lDAGM=";
          allowedIPs = ["0.0.0.0/0"];
          endpoint = "212.56.52.56:1337";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
