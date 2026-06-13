{config, ...}: {
  imports = [./wireguard.nix];

  nixarr = {
    enable = true;

    mediaDir = "/mnt/files/media";
    stateDir = "/mnt/files/media/.state/nixarr";

    vpn = {
      enable = true;
      wgConf = "/run/pia-wg/wg.conf";
    };

    transmission = {
      enable = true;
      peerPort = 51413;
      vpn.enable = true;
      extraSettings = {
        download-queue-enabled = true;
        download-queue-size = 3;
        seed-queue-enabled = true;
        seed-queue-size = 20;
      };
    };

    jellyfin = {
      enable = true;
      openFirewall = true;
    };
    jellyseerr.enable = true;
    lidarr = {
      enable = true;
      openFirewall = true;
    };
    prowlarr = {
      enable = true;
      openFirewall = true;
    };
    radarr = {
      enable = true;
      openFirewall = true;
    };
    sonarr = {
      enable = true;
      openFirewall = true;
    };
    seerr.openFirewall = true;
  };

  services = {
    flaresolverr = {
      enable = true;
      openFirewall = true;
    };
  };
}
