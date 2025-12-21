# AGENTS.md

## Commands
- **Format**: `nix fmt` (uses alejandra)
- **Check flake**: `nix flake check`
- **Update machine**: `clan machines update <machine>` (e.g., wopr, joshua, falken)
- **Rebuild NixOS locally**: `sudo nixos-rebuild switch --flake .#<machine>`
- **Rebuild Darwin**: `sudo darwin-rebuild switch --flake .#`

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
