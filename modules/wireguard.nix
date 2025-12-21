{config, ...}: {
  imports = [./wireguard-secrets.nix];

  networking.wg-quick.interfaces = {
    wg0 = {
      autostart = false;
      address = ["10.20.155.53/32"];
      dns = ["10.0.0.243"];
      privateKeyFile = config.clan.core.vars.generators.wireguard-vpn.files.wg-key.path;

      peers = [
        {
          publicKey = "5u3eMHBFKLCzKcezy/Xd/F7EqNP75Ixw0ud9hlKYkjg=";
          allowedIPs = ["0.0.0.0/0"];
          endpoint = "149.22.95.149:1337";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
