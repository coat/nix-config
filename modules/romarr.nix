# ROMarr: the *arr for games (find, verify and organize a ROM library). Runs
# the upstream Python app natively — no Docker — filing ROMs into RomM's
# library and verifying them against No-Intro/Redump DATs.
#
# The download client is qBittorrent (nixarr, in the wg netns), configured in
# the UI at Settings → Download Clients. qBittorrent's WebUI API is reachable
# at http://192.168.15.1:8085 (no auth from the 192.168.15.0/24 whitelist); its
# completed files live under /var/lib/nixarr/qbittorrent-downloads on the host
# filesystem, which ROMarr reads directly. Only non-secret defaults are seeded
# here; the Prowlarr API key and any login are configured in the UI.
{
  lib,
  pkgs,
  ...
}: {
  systemd.services.romarr = {
    description = "ROMarr game & ROM search + download manager";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    environment = {
      ROMARR_PORT = "6868";

      # State (settings, history, API key) is a single JSON file.
      ROMARR_DATA = "/var/lib/romarr/romarr.json";

      # Plain folder library: ROMarr files ROMs into RomM's platform folders
      # and RomM picks them up on its own scan. Switch to LIBRARY_KIND=romm in
      # the UI (Settings → Libraries) if you want the API integration instead.
      LIBRARY_KIND = "folder";
      LIBRARY_PATH = "/mnt/files/media/library/roms";

      # No-Intro DATs for verification (the same set igir uses). No-Intro only:
      # the other DAT groups (Non-Redump, Source Code, Unofficial) aren't used
      # and loading them all doubles ROMarr's resident memory.
      DAT_PATH = "/mnt/files/media/library/dats/No-Intro";

      # Prowlarr URL is non-secret; the API key goes in the UI.
      PROWLARR_URL = "http://127.0.0.1:9696";

      TZ = "America/Los_Angeles";
      PYTHONUNBUFFERED = "1";
    };

    serviceConfig = {
      ExecStart = lib.getExe pkgs.romarr;
      Restart = "always";
      RestartSec = "10s";

      # Run as sadbeast, the owner of RomM's library and the DATs, so ROMarr can
      # write imports and read DATs; the `media` group lets it read
      # Transmission's completed downloads (0775 … media).
      User = "sadbeast";
      Group = "media";

      StateDirectory = "romarr";
      StateDirectoryMode = "0750";

      # Batch service, like the other arrs, but Python + DAT verification is
      # heavier than the Go/.NET arrs: it parses the No-Intro DATs (~250 XMLs)
      # plus the ~17k-file library catalogue and TitleDB into ~1G of resident
      # objects. Keep MemoryHigh above that so the cgroup never throttles the
      # startup scan; MemoryMax is the runaway ceiling.
      MemoryHigh = "1.5G";
      MemoryMax = "2G";
      CPUQuota = "50%";
      IOSchedulingClass = "idle";
      IOSchedulingPriority = 7;

      # Hardening. Transmission's downloads stay readable (read-only under
      # strict); only /var/lib/romarr (StateDirectory) and the media tree are
      # writable.
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ReadWritePaths = ["/mnt/files/media"];
    };
  };

  networking.firewall.allowedTCPPorts = [6868];
}
