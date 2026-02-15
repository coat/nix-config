{config, ...}: {
  imports = [./wireguard.nix];

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

    jellyfin.enable = true;
    jellyseerr.enable = true;
    lidarr.enable = true;
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
  };
}
