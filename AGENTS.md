# AGENTS.md

Tool-agnostic guide for any coding agent working in this repo. Claude Code
reads it via `@AGENTS.md` in `CLAUDE.md`. Step-by-step procedures live in
`.agents/skills/` (symlinked as `.claude/skills/`).

## Layout gotchas

Only the non-obvious parts — everything else is discoverable with `ls`.

- `clan.nix` is the entry point for NixOS machines: `machineConfigs` lists
  each host's tags/system/profile/user, and `mkMachine` (also in `clan.nix`)
  composes, in order: `modules/global.nix`, `modules/profiles/<profile>.nix`
  (desktop | server | vm), `users/<user>/nixos.nix`, optional
  `users/<user>/<profile>.nix` (that user's extras for the profile), and HM
  from `users/<user>/home.nix` + optional `machines/<host>/home.nix`.
- `machines/` vs `hosts/` split is intentional: clan **auto-discovers**
  `machines/<host>/{configuration.nix,disko.nix,facter.json}`, so non-clan
  hosts (darwin) live in `hosts/`. Do not unify them.
- `modules/base.nix` is shared by machines *and* microvm guests;
  `modules/global.nix` adds host-only settings on top.
- Home-manager: every user's `home.nix` imports `users/common/home-base.nix`
  and sets `me.{username,realName,email}`. `desktop-home.nix` is HM desktop
  add-ons; `darwin.nix` is the macOS HM bundle. Features are in
  `users/features/`.
- Stylix: `modules/stylix/theme.nix` is the one theme; `nixos.nix` (desktops,
  HM inherits it) and `hm-terminal.nix` (servers, microvms, devcontainers).
- One nixpkgs instance per system: `pkgsFor` in `flake.nix` (built by
  `lib/mk-pkgs.nix`), used by clan machines, darwin and standalone HM.
- `microvms/<name>.nix` files are enumerated by `modules/microvm.nix`; the
  filename becomes the VM name.
- `overlays/default.nix`: `additions` (custom packages from `pkgs/`),
  `modifications` (pinned/overridden upstream; currently empty), `herdr`
  (upstream flake overlay). Consume via `outputs.overlays.all`.
- `vars/shared/zerotier-ip-<host>-zerotier/ip/value` is read **at eval time**
  (`modules/zerotier-hosts.nix` maps every peer's hostname to its ZeroTier
  IP). A new machine resolves by name over ZeroTier only after its vars exist.
- `system.stateVersion` comes from clan's per-machine `state-version` var;
  only joshua and wopr override it in `configuration.nix`.

## Commands

- **Validate everything**: `nix flake check --no-write-lock-file`
  (evaluates every NixOS + HM config; must pass before you report success).
  Do not add `--no-build`: stylix reads the base16 scheme at eval time (IFD).
- **Darwin** (not covered by flake check on Linux):
  `nix eval --no-write-lock-file 'path:.#darwinConfigurations."k-smith-3qcj".config.system.build.toplevel.drvPath'`
- **Format**: `nix fmt .` (alejandra; currently clean — keep it that way)
- **Update machine remotely**: `clan machines update <machine>`
- **Rebuild NixOS locally**: `sudo nixos-rebuild switch --flake .#<machine>`
- **Rebuild Darwin**: `sudo darwin-rebuild switch --flake .#`

Faster targeted evals while iterating:

```sh
nix eval --no-write-lock-file "path:.#nixosConfigurations.<machine>.config.system.build.toplevel.drvPath"
nix eval --no-write-lock-file "path:.#nixosConfigurations.<machine>.config.home-manager.users.<user>.home.stateVersion"
```

Comparing toplevel drvPaths before/after is the quickest way to prove a
refactor is a no-op for a host.

## Rules

- `git add -N` new files before any `nix eval`/`nix build` — flakes only see
  tracked files.
- `evaluation warning: stdenv.isLinux/isDarwin is deprecated` comes from an
  upstream input, not this repo; ignore it. Any other warning is ours to fix.
- Secrets go through clan vars only (`clan.core.vars.generators.*`, stored
  under `vars/`; `sops/` is clan's backend, never edit it by hand). Never
  commit unencrypted secrets.
- Build-verify before saying something works; say explicitly whether a change
  has been deployed (`clan machines update`) or only evaluated.

## Procedures (skills)

- Add a NixOS machine → `.agents/skills/adding-machine/SKILL.md`
- Add a user → `.agents/skills/adding-user/SKILL.md`
- Add a darwin host → `.agents/skills/adding-darwin-host/SKILL.md`
- Add a microvm guest → `.agents/skills/creating-microvm/SKILL.md`
- Update / audit herdr plugin packages → `.agents/skills/updating-herdr-plugins/SKILL.md`
