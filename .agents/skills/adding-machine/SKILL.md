---
name: adding-machine
description: "Adds a new NixOS machine managed by clan. Use when the user asks to add, create, or onboard a new NixOS host, machine, or server."
---

# Adding a Machine (NixOS / clan)

Clan auto-discovers `machines/<host>/configuration.nix`, `disko.nix` and
`facter.json`; the rest is wired by `mkMachine` in `clan.nix` from the
`machineConfigs` entry.

## Steps

1. **Append an entry to `machineConfigs` in `clan.nix`:**
   ```nix
   <host> = {
     tags = ["personal"];          # or ["work"]
     system = "x86_64-linux";      # or aarch64-linux
     profile = "desktop";          # desktop | server | vm
     user = "sadbeast";            # must match a users/<user>/ directory
     # buildHost = "root@joshua";  # optional: remote builder for `clan machines update`
     # requireExplicitUpdate = true;  # optional: opt out of bulk updates
   };
   ```
   If the machine should be reachable by `clan machines update`, add its
   address under `inventory.instances.internet` in the same file.
2. **Create `machines/<host>/configuration.nix`** with host-only settings
   (services, firewall, hostname-specific hardware tweaks).
3. **Hardware:** the clan way (used by cheyenne, crystalpalace, falken) is
   - `clan machines init-hardware-config <host> --target-host root@<ip>`
     → writes `machines/<host>/facter.json`
   - `clan templates apply disk single-disk <host> --set mainDisk <dev>`
     → writes `machines/<host>/disko.nix`
   - `clan machines install <host> --target-host root@<ip>`
   Only fall back to a hand-written `hardware-configuration.nix` (imported
   from `configuration.nix`, like joshua/wopr) for machines installed
   outside clan.
4. **Optional: `machines/<host>/home.nix`** for per-host HM tweaks (sway
   monitor layout, terminal choice, etc.). `mkMachine` auto-detects it.
5. **Profiles** live in `modules/profiles/<profile>.nix`. Only add
   `users/<user>/<profile>.nix` if the user needs extra NixOS config on that
   profile; `mkMachine` imports it when present.
6. **`git add -N` the new files** so Nix can see them, then verify:
   ```sh
   nix eval --no-write-lock-file "path:.#nixosConfigurations.<host>.config.system.build.toplevel.drvPath"
   nix flake check --no-write-lock-file
   ```
7. **Format** with `nix fmt .`.
8. **Deploy:** `clan machines update <host>` (or `clan machines install` for
   a fresh machine). After the first deploy, run `clan vars generate` so its
   ZeroTier IP lands in `vars/shared/` and other hosts can resolve it.

## Key Files

- `clan.nix` — `machineConfigs`, `mkMachine`, inventory instances.
- `machines/<host>/` — per-host NixOS config (+ disko/facter).
- `modules/profiles/<profile>.nix` — desktop | server | vm host profiles.
- `users/<user>/<profile>.nix` — optional per-user extras for a profile.
