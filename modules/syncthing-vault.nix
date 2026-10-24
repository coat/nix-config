# Extra config for every peer of the clan syncthing instance (clan.nix).
{lib, ...}: {
  # clan's syncthing service runs as a dedicated user by default; run it as
  # sadbeast so the synced Obsidian vault in ~/docs stays ours.
  services.syncthing = {
    user = "sadbeast";
    group = lib.mkForce "users";
    # per-device UI state; syncing it just produces conflict files
    settings.folders.obsidian-personal.ignorePatterns = [
      ".obsidian/workspace.json"
      ".obsidian/workspace-mobile.json"
    ];
  };
}
