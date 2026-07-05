{
  imports = [./wireguard.nix];

  nixarr = {
    enable = true;

    mediaDir = "/mnt/files/media";
    stateDir = "/var/lib/nixarr";

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
        seed-queue-size = 5;
        blocklist-enabled = false;
        cache-size-mb = 128;
        peer-limit-global = 200;
        peer-limit-per-torrent = 50;
      };
    };

    jellyfin = {
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

    seerr.enable = true;
    seerr.openFirewall = true;

    sonarr.enable = true;
    sonarr.openFirewall = true;
  };

  services = {
    flaresolverr = {
      enable = true;
      openFirewall = true;
    };
  };

  systemd.services = {
    radarr.serviceConfig = {
      MemoryMax = "384M";
      CPUQuota = "50%";
      IOSchedulingClass = "idle";
      IOSchedulingPriority = 7;
    };
    sonarr.serviceConfig = {
      MemoryMax = "384M";
      CPUQuota = "50%";
      IOSchedulingClass = "idle";
      IOSchedulingPriority = 7;
    };
    prowlarr.serviceConfig = {
      MemoryMax = "384M";
      CPUQuota = "50%";
      IOSchedulingClass = "idle";
      IOSchedulingPriority = 7;
    };
    seerr.serviceConfig = {
      MemoryMax = "384M";
      CPUQuota = "50%";
      IOSchedulingClass = "idle";
      IOSchedulingPriority = 7;
    };
    flaresolverr.serviceConfig = {
      MemoryMax = "768M";
      CPUQuota = "100%";
      IOSchedulingClass = "idle";
      IOSchedulingPriority = 7;
    };
  };
}
