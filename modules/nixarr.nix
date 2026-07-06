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
        rpc-host-whitelist = "transmission.local";
        download-queue-enabled = true;
        download-queue-size = 3;
        seed-queue-enabled = true;
        seed-queue-size = 5;
        blocklist-enabled = false;
        # Keep ALL torrent I/O on the SSD, away from the SMR USB media drive:
        # it is BOT-only (queue depth 1), write-through, and collapses to
        # ~2 IO/s under SMR garbage collection. Transmission 4 does file I/O
        # on its RPC/session thread, so one slow USB read freezes the daemon
        # (Idle status, RPC timeouts). Torrents download AND seed from here;
        # sonarr/radarr import to the library with a cross-filesystem
        # sequential copy, the one workload the USB drive handles well.
        download-dir = "/var/lib/nixarr/transmission/downloads";
        incomplete-dir = "/var/lib/nixarr/transmission/incomplete";
        incomplete-dir-enabled = true;
        watch-dir = "/var/lib/nixarr/transmission/watch";
        # Seeding caps bound SSD usage (146G free); the arrs remove
        # torrents after import once seeding goals are met.
        ratio-limit = 2;
        ratio-limit-enabled = true;
        idle-seeding-limit = 4320; # minutes; stop seeds idle for 3 days
        idle-seeding-limit-enabled = true;
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

  systemd.tmpfiles.rules = [
    # o+rx on transmission's home: sonarr/radarr run with PrivateUsers=true,
    # where foreign uids/gids collapse to nobody/nogroup, so group-based access
    # to the downloads dir fails inside their sandbox and imports error with
    # "path does not exist or is not accessible". World-traverse fixes it; the
    # dir holds no secrets (settings.json itself stays 0600).
    "d /var/lib/nixarr/transmission 0755 transmission media -"
    "d /var/lib/nixarr/transmission/downloads 0775 transmission media -"
    "d /var/lib/nixarr/transmission/incomplete 0755 transmission media -"
    "d /var/lib/nixarr/transmission/watch 0775 transmission media -"
  ];

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
