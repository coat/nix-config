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
        idle-seeding-limit = 10080; # minutes; stop seeds idle for 7 days
        idle-seeding-limit-enabled = true;
        cache-size-mb = 32;
        preallocation = 2; # full — avoid fragmentation on the SSD
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
    # Jellyfin is the interactive, user-facing service: give it CPU and IO
    # priority over the batch services so playback doesn't stutter when
    # imports/downloads are running.
    jellyfin.serviceConfig = {
      CPUWeight = 500; # default is 100; batch services stay at default
      IOWeight = 500;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 0; # highest best-effort priority
    };
    # The arrs' cgroup memory is mostly page cache from multi-GB import
    # copies, and dirty pages drain no faster than the SMR drive writes
    # back — a hard 384M cap OOM-killed them mid-import in a loop.
    # MemoryHigh reclaims/throttles instead; MemoryMax is a last resort.
    radarr.serviceConfig = {
      MemoryHigh = "512M";
      MemoryMax = "1G";
      CPUQuota = "50%";
      IOSchedulingClass = "idle";
      IOSchedulingPriority = 7;
    };
    sonarr.serviceConfig = {
      MemoryHigh = "512M";
      MemoryMax = "1G";
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
