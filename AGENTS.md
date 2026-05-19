# AGENTS.md

This file is the canonical guide for any automated assistant working in this
repo. It is tool-agnostic — every command runs in a normal shell with the
tooling listed under "Commands". No specific assistant or IDE is assumed.

## Repo Layout

```
flake.nix       Flake inputs/outputs. Builds clan, darwin hosts, standalone HM.
clan.nix        Clan machine + user + wifi + zerotier instance definitions.
lib/            Pure-Nix helpers: mk-pkgs, ssh-keys.
modules/        NixOS modules — services, profiles (desktop-host), HM wiring.
machines/       Per-host NixOS config (clan auto-discovers <host>/configuration.nix).
                Optional machines/<host>/home.nix is auto-wired by mkMachine.
hosts/          Non-clan host configs — currently darwin/.
microvms/       One file per microvm guest (consumed by modules/microvm.nix).
users/          Home-manager content.
  common/home-base.nix     Parametric HM base (username, email, extraImports).
  features/                Composable feature modules: git, zsh, tmux, dev, desktop/, nixvim/.
  <user>/home.nix          Base HM bundle per user.
  <user>/desktop-home.nix  HM desktop add-ons (browser profile, gtk, dconf, …).
  <user>/<profile>.nix     NixOS-side per-profile module (e.g. desktop.nix, server.nix, vm.nix).
  <user>/nixos.nix         System user account (calls modules/user-account.nix).
  <user>/darwin.nix        Darwin-specific HM bundle.
overlays/       Three-layer overlay: additions / modifications / llm-agents (merged in `all`).
pkgs/           Custom packages.
sops/           Encrypted secrets (sops-nix).
vars/           Clan-managed variables and generated secrets.
```

## Commands

- **Format**: `nix fmt`
- **Check flake**: `nix flake check --no-write-lock-file`
- **Update machine remotely**: `clan machines update <machine>` (e.g. `wopr`, `joshua`)
- **Rebuild NixOS locally**: `sudo nixos-rebuild switch --flake .#<machine>`
- **Rebuild Darwin**: `sudo darwin-rebuild switch --flake .#`

### Validation evals (no deploy)

```sh
nix eval --no-write-lock-file 'path:.#clan.inventory.machines'
nix eval --no-write-lock-file "path:.#nixosConfigurations.<machine>.config.system.stateVersion"
nix eval --no-write-lock-file 'path:.#darwinConfigurations."<host>".config.system.stateVersion'
nix eval --no-write-lock-file 'path:.#homeConfigurations."<name>".config.home.stateVersion'
```

## Add a Machine (NixOS / clan)

1. Append an entry to `machineConfigs` in `clan.nix`:
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
2. Create `machines/<host>/configuration.nix` (NixOS) and
   `machines/<host>/hardware-configuration.nix` (from `nixos-generate-config`).
3. Optionally create `machines/<host>/home.nix` for per-host HM tweaks
   (sway monitor layout, terminal choice, etc.). `mkMachine` auto-detects it.
4. If the user/profile pair is new (e.g. a new `users/<user>/desktop.nix`),
   create that file too — it picks which NixOS profile module to import.
5. `git add -N` the new files so Nix can see them, then
   `nix flake check --no-write-lock-file`.
6. Deploy: `clan machines update <host>`.

## Add a User

1. Add an entry to `userInstanceConfigs` in `clan.nix`:
   ```nix
   <name>-user = {
     tags = ["personal"];        # which machines pick up this user
     user = "<name>";
     groups = ["wheel" "media"]; # all groups, including capability ones
   };
   ```
2. Add the user's ssh keys to `lib/ssh-keys.nix`.
3. Create `users/<name>/`:
   - `home.nix` — base HM bundle (use `users/common/home-base.nix`).
   - `nixos.nix` — system user account (calls `modules/user-account.nix`).
   - `<profile>.nix` for each profile that user uses (`desktop.nix`, `server.nix`, `vm.nix`).
   - Optional: `desktop-home.nix` for HM desktop add-ons.
   - Optional: `darwin.nix` if the user has a macOS host.
4. `nix flake check --no-write-lock-file`.

## Add a Darwin Host

Append to `darwinHostConfigs` in `flake.nix`:
```nix
"<host>" = {
  system = "aarch64-darwin";
  user = "<user>";
  hostConfig = ./hosts/darwin/<host>/configuration.nix;
};
```
Then create the host config file. `mkDarwin` wires nix-index, stylix, and
home-manager automatically.

## Add a MicroVM Guest

See `.agents/skills/creating-microvm/SKILL.md`. In short: create
`microvms/<name>.nix` with the per-VM args; `modules/microvm.nix` enumerates
the directory and instantiates each guest via `modules/microvm-base.nix`.

## Conventions

- Format with `alejandra` (`nix fmt`).
- Secrets via sops-nix; never commit unencrypted secrets.
- The `machines/` vs `hosts/` split is intentional — clan auto-discovers
  `machines/`, so non-clan hosts (darwin) live in `hosts/`.
- Three-layer overlay model in `overlays/default.nix`: `additions` for custom
  packages, `modifications` for pinned/overridden upstream, `llm-agents` for
  the numtide overlay. Use `outputs.overlays.all` to consume everything.
