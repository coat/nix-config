---
name: adding-darwin-host
description: "Adds a new macOS / nix-darwin host. Use when the user asks to add, create, or set up a Mac, macOS, or darwin machine."
---

# Adding a Darwin Host

Darwin hosts are **not** clan machines. They live in `hosts/darwin/` (not
`machines/`, which clan auto-discovers) and are built by `mkDarwin` in
`flake.nix`.

## Steps

1. **Append to `darwinHostConfigs` in `flake.nix`:**
   ```nix
   "<host>" = {
     system = "aarch64-darwin";
     user = "<user>";
     hostConfig = ./hosts/darwin/<host>/configuration.nix;
   };
   ```
2. **Create `hosts/darwin/<host>/configuration.nix`.** `mkDarwin` wires
   nix-index, stylix, and home-manager automatically.
3. **Ensure `users/<user>/darwin.nix` exists** (Darwin-specific HM bundle).
4. **`git add -N` the new files**, then verify:
   ```sh
   nix eval --no-write-lock-file 'path:.#darwinConfigurations."<host>".config.system.stateVersion'
   ```
5. **Format** with `nix fmt`.
6. **Deploy on the Mac:** `sudo darwin-rebuild switch --flake .#`

## Key Files

- `flake.nix` — `darwinHostConfigs`, `mkDarwin`.
- `hosts/darwin/<host>/configuration.nix` — host config.
- `users/<user>/darwin.nix` — HM bundle for macOS.
