{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [./wireguard.nix];

  nixarr = {
    enable = true;

    # nixarr-py generates its Jellyfin client from the OpenAPI spec of the
    # running Jellyfin version, but looks the spec's hash up in a hard-coded
    # table that stops at 12.2; nixpkgs ships 12.4. Supply the missing hash
    # through python-deps.nix's fetchurl argument. Drop once upstream nixarr
    # knows 12.4.
    nixarr-py.package = let
      src = "${inputs.nixarr}/nixarr/lib/nixarr-py";
      jellyfin = config.nixarr.jellyfin.package;
      fetchurl = args:
        pkgs.fetchurl (args
          // lib.optionalAttrs (lib.hasSuffix "/jellyfin-openapi-12.4.json" args.url) {
            hash = "sha256-AqYGSRa34I8fHY1//B+xx2I98ON4cp/Nf9NTdmhoA24=";
          });
    in
      (pkgs.callPackage src {inherit jellyfin;}).overridePythonAttrs (_: {
        dependencies = pkgs.callPackage "${src}/python-deps.nix" {inherit jellyfin fetchurl;};
      });

    mediaDir = "/mnt/files/media";
    stateDir = "/var/lib/nixarr";

    vpn = {
      enable = true;
      wgConf = "/run/pia-wg/wg.conf";
    };

    qbittorrent = {
      enable = true;
      peerPort = 51413;
      vpn.enable = true;
      openFirewall = true; # qui WebUI (port 5252)
      extraConfig = {
        BitTorrent = {
          # Keep ALL torrent I/O on the SSD, away from the SMR USB media drive
          # (same reasons as the old transmission setup — see the comment
          # history). Override nixarr's mediaDir default for both the session
          # and downloads paths.
          "Session\\DefaultSavePath" = "/var/lib/nixarr/qbittorrent/downloads";
          "Session\\TempPath" = "/var/lib/nixarr/qbittorrent/.incomplete";
          # Seeding caps bound SSD usage (146G free); the arrs remove torrents
          # after import once these are met.
          "Session\\GlobalMaxRatio" = "2.0";
          "Session\\GlobalMaxSeedingMinutes" = "10080";
        };
        Preferences = {
          "Downloads\\SavePath" = "/var/lib/nixarr/qbittorrent/downloads";
          "Downloads\\TempPath" = "/var/lib/nixarr/qbittorrent/.incomplete";
        };
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
    # o+rx on qbittorrent's home: sonarr/radarr run with PrivateUsers=true,
    # where foreign uids/gids collapse to nobody/nogroup, so group-based access
    # to the downloads dir fails inside their sandbox and imports error with
    # "path does not exist or is not accessible". World-traverse fixes it; the
    # dir holds no secrets (qBittorrent's config stays 0700).
    "d /var/lib/nixarr/qbittorrent 0755 qbittorrent media -"
    "d /var/lib/nixarr/qbittorrent/downloads 0775 qbittorrent media -"
    "d /var/lib/nixarr/qbittorrent/.incomplete 0755 qbittorrent media -"
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
