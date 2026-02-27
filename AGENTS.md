# AGENTS.md

## Commands
- **Format**: `nix fmt` (uses alejandra)
- **Check flake**: `nix flake check`
- **Update machine**: `clan machines update <machine>` (e.g., wopr, joshua, falken)
- **Rebuild NixOS locally**: `sudo nixos-rebuild switch --flake .#<machine>`
- **Rebuild Darwin**: `sudo darwin-rebuild switch --flake .#`

## Validation Checks
- **NixOS output eval**: `nix eval --no-write-lock-file 'path:.#nixosConfigurations.<machine>.config.system.stateVersion'`
- **Home-manager output eval**: `nix eval --no-write-lock-file 'path:.#homeConfigurations."<name>".config.home.stateVersion'`
- **Darwin output eval**: `nix eval --no-write-lock-file 'path:.#darwinConfigurations."<name>".config.system.stateVersion'`
- **Clan inventory eval**: `nix eval --no-write-lock-file 'path:.#clan.inventory.machines'`
- **Clan instances eval**: `nix eval --no-write-lock-file 'path:.#clan.inventory.instances'`

## Where To Edit
- **Add/update clan machine metadata**: `clan.nix` in `machineConfigs`
- **Add/update clan user role instances**: `clan.nix` in `userInstanceConfigs`
- **Add/update wifi mappings**: `clan.nix` in `wifiInstanceConfig`
- **Host-specific NixOS service/config**: `machines/<machine>/configuration.nix`
- **Shared NixOS modules**: `modules/`
- **Home-manager user profiles**: `users/<user>/`
- **Darwin host config**: `hosts/darwin/...`

## Architecture
- **Flake-based NixOS config** using clan-core for multi-machine management
- `machines/` - NixOS machine configs (cheyenne, crystalpalace, falken, joshua, wopr)
- `hosts/` - Non-clan hosts (darwin/macOS)
- `modules/` - Shared NixOS modules (desktop, docker, wireguard, etc.)
- `users/` - Home-manager user configs (kent, sadbeast, vscode)
- `overlays/` - Nixpkgs overlays
- `pkgs/` - Custom package definitions
- `sops/` - Encrypted secrets (sops-nix)

## Code Style
- Use `alejandra` for Nix formatting (run `nix fmt`)
- Follow nixpkgs conventions for module options and package definitions
- Secrets managed via sops; never commit unencrypted secrets
