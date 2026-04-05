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
- `flake.nix` - Flake inputs/outputs, devcontainer and darwin configs
- `clan.nix` - Clan machine definitions, user/wifi/zerotier instances, mk* helpers
- `machines/` - NixOS machine configs (cheyenne, crystalpalace, falken, joshua, wopr)
- `hosts/` - Non-clan hosts (darwin/macOS)
- `lib/` - Shared utility functions and data (mk-pkgs, ssh-keys)
- `modules/` - Shared NixOS modules (desktop, docker, wireguard, etc.)
- `users/` - Home-manager user configs (kent, sadbeast, vscode, nix-on-droid)
  - `common/home-base.nix` - Parametric base config (username, email, extraImports)
  - `features/` - Composable feature modules (git, zsh, tmux, desktop/, nixvim/)
  - Per-user dirs compose features via `extraImports` into home-base
- `overlays/` - Three-layer overlay system: additions (custom pkgs), modifications (pinned versions), llm-agents
- `pkgs/` - Custom package definitions
- `sops/` - Encrypted secrets (sops-nix)
- `vars/` - Clan-managed variables and generated secrets (per-machine and shared)

### Key Flake Inputs
- **clan-core** - Multi-machine orchestration and deployment
- **home-manager** - User-level config, integrated into NixOS via clan and standalone for devcontainers
- **nixvim** - Declarative Neovim configuration
- **stylix** - System-wide theming
- **darwin** - macOS/nix-darwin support
- **microvm** - MicroVM host support
- **nixarr** - Arr stack media management
- **llm-agents** - Claude Code and related tools

## Code Style
- Use `alejandra` for Nix formatting (run `nix fmt`)
- Follow nixpkgs conventions for module options and package definitions
- Secrets managed via sops; never commit unencrypted secrets
