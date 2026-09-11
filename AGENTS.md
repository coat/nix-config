# AGENTS.md

Tool-agnostic guide for any coding agent working in this repo. Claude Code
reads it via `@AGENTS.md` in `CLAUDE.md`. Step-by-step procedures live in
`.agents/skills/` (symlinked as `.claude/skills/`).

## Layout gotchas

Only the non-obvious parts — everything else is discoverable with `ls`.

- `machines/` vs `hosts/` split is intentional: clan **auto-discovers**
  `machines/<host>/configuration.nix`, so non-clan hosts (darwin) live in
  `hosts/`. Do not unify them.
- `mkMachine` (`flake.nix`) auto-wires `machines/<host>/home.nix` if present.
- `users/<user>/<profile>.nix` (`desktop.nix`, `server.nix`, `vm.nix`) is the
  NixOS-side module selecting a profile; `users/<user>/home.nix` is the HM
  bundle; `desktop-home.nix` is HM desktop add-ons; `darwin.nix` is the macOS
  HM bundle.
- `microvms/<name>.nix` files are enumerated by `modules/microvm.nix`; the
  filename becomes the VM name.
- `overlays/default.nix` has three layers: `additions` (custom packages),
  `modifications` (pinned/overridden upstream), `llm-agents` (numtide overlay).
  Consume via `outputs.overlays.all`.

## Commands

- **Format**: `nix fmt` (alejandra)
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

## Rules

- `git add -N` new files before any `nix eval`/`nix build` — flakes only see
  tracked files.
- Prefer the targeted `nix eval` checks above; `nix flake check` and `nix fmt`
  have pre-existing failures unrelated to most changes, so don't chase those.
- Secrets go through sops-nix (`sops/`) or clan vars (`vars/`); never commit
  unencrypted secrets.
- Build-verify before saying something works; say explicitly whether a change
  has been deployed (`clan machines update`) or only evaluated.

## Procedures (skills)

- Add a NixOS machine → `.agents/skills/adding-machine/SKILL.md`
- Add a user → `.agents/skills/adding-user/SKILL.md`
- Add a darwin host → `.agents/skills/adding-darwin-host/SKILL.md`
- Add a microvm guest → `.agents/skills/creating-microvm/SKILL.md`
