---
name: adding-user
description: "Adds a new user account with home-manager config across clan machines. Use when the user asks to add, create, or onboard a new user."
---

# Adding a User

Users are declared in `clan.nix` and get their content from `users/<name>/`.
Which machines pick up a user is controlled by tags.

## Steps

1. **Add an entry to `userInstanceConfigs` in `clan.nix`:**
   ```nix
   <name>-user = {
     tags = ["personal"];        # which machines pick up this user
     user = "<name>";
     groups = ["wheel" "media"]; # all groups, including capability ones
   };
   ```
2. **Add the user's ssh keys** to `lib/ssh-keys.nix`.
3. **Create `users/<name>/`:**
   - `home.nix` — HM bundle: import `../common/home-base.nix` plus features,
     and set `me = { username = "<name>"; realName = "…"; email = "…"; };`.
   - `nixos.nix` — system account: `users.users.<name> = { isNormalUser;
     shell; openssh.authorizedKeys.keys; }` (groups come from clan.nix).
   - Optional `<profile>.nix` (`desktop.nix`, `server.nix`, `vm.nix`) — extra
     NixOS config this user needs only on that profile (e.g. a secret). The
     profile itself is `modules/profiles/<profile>.nix`, picked per machine.
   - Optional: `desktop-home.nix` — HM desktop add-ons (browser profile, gtk, dconf, …).
   - Optional: `darwin.nix` — Darwin-specific HM bundle.
   Use an existing `users/<user>/` as the template.
4. **`git add -N` the new files**, then verify:
   ```sh
   nix eval --no-write-lock-file 'path:.#nixosConfigurations.<machine>.config.home-manager.users."<name>".home.stateVersion'
   nix flake check --no-write-lock-file
   ```
5. **Format** with `nix fmt .`.

## Key Files

- `clan.nix` — `userInstanceConfigs`.
- `lib/ssh-keys.nix` — authorized keys per user.
- `users/common/home-base.nix` — shared HM base.
- `users/features/` — composable HM feature modules (git, zsh, tmux, dev, desktop/, nixvim/).
