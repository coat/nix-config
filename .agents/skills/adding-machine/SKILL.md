---
name: adding-machine
description: "Adds a new NixOS machine managed by clan. Use when the user asks to add, create, or onboard a new NixOS host, machine, or server."
---

# Adding a Machine (NixOS / clan)

Clan auto-discovers `machines/<host>/configuration.nix`; the rest is wired by
`mkMachine` in `flake.nix` from the `clan.nix` entry.

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
2. **Create `machines/<host>/configuration.nix`** and
   `machines/<host>/hardware-configuration.nix` (from `nixos-generate-config`).
3. **Optional: `machines/<host>/home.nix`** for per-host HM tweaks (sway
   monitor layout, terminal choice, etc.). `mkMachine` auto-detects it.
4. **If the user/profile pair is new** (e.g. no `users/<user>/desktop.nix`
   yet), create that file — it picks which NixOS profile module to import.
5. **`git add -N` the new files** so Nix can see them, then verify:
   ```sh
   nix eval --no-write-lock-file 'path:.#clan.inventory.machines'
   nix eval --no-write-lock-file "path:.#nixosConfigurations.<host>.config.system.stateVersion"
   ```
6. **Format** with `nix fmt`.
7. **Deploy:** `clan machines update <host>`.

## Key Files

- `clan.nix` — `machineConfigs` (inventory) and `userInstanceConfigs`.
- `flake.nix` — `mkMachine` wires profile, user, and optional `home.nix`.
- `machines/<host>/` — per-host NixOS config.
- `users/<user>/<profile>.nix` — NixOS-side profile module per user.
