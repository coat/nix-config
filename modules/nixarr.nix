{
  config,
  lib,
  pkgs,
  ...
}: {
  nixarr = {
    enable = true;

    mediaDir = "/mnt/files/media";
    stateDir = "/mnt/files/media/.state/nixarr";

    vpn = {
      enable = true;
      wgConf = config.clan.core.vars.generators.wireguard-vpn.files.wg-conf.path;
    };

    transmission = {
      enable = true;
      vpn.enable = true;
    };

    bazarr.enable = true;
    lidarr.enable = true;
    plex.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    readarr.enable = true;
    sonarr.enable = true;
  };

  services = {
    flaresolverr = {
      enable = true;
      openFirewall = true;
    };

    overseerr = {
      enable = true;
      openFirewall = true;
    };
  };

  clan.core.vars.generators.wireguard-vpn = {
    files.wg-conf = {
      secret = true;
    };
    prompts.private-key = {
      description = "WireGuard VPN private key";
      type = "hidden";
    };
    script = ''
      priv_key="$(cat "$prompts/private-key")"
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
