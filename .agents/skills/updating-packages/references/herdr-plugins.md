# Herdr plugins

Herdr-specific additions to the `updating-packages` procedure for
`pkgs/herdr-*`. These plugins are packaged by hand rather than via
`herdr plugin install`, so beyond their own upstream they are coupled to
herdr's plugin loader and to the consumer, `users/features/herdr.nix`.

## Inventory: the herdr input

Plugin-loading semantics live in the herdr flake input. Record it alongside
the plugin versions:

```sh
jq -r '.nodes.herdr.locked | "\(.rev[0:12]) \(.lastModified | todate)"' flake.lock
git log -1 --format=%cd -- pkgs/herdr-*
```

If it moved since the last plugin bump (or in an uncommitted `flake.lock`),
run the **herdr input** checks below even when no plugin is behind. Review
its diff the same way as a plugin's:

```sh
gh api repos/herdrdev/herdr/compare/<old>...<new> --jq '.files[].filename' \
  | grep -E 'plugin|integration/assets'
```

## Diff review: the manifest

In every plugin diff, check `herdr-plugin.toml` for a new
`min_herdr_version` (compare with the locked herdr), or for new
`[[startup]]`/`[[build]]`/`[[actions]]` entries. New commands mean new
interpreters or tools that need pinning the same way the existing ones are.

## Couplings per plugin

### herdr-auto-title (Go, `subPackages`)

| Workaround | Depends on | Check |
|---|---|---|
| `mv $out/bin/<name> $out/<name>`; `cp $src/herdr-plugin.toml` | Manifest `[[startup]]` command is a relative `./herdr-auto-title`; herdr runs it with `plugin_root` as cwd | Manifest command path unchanged; binary name unchanged; no new files the manifest references |
| `subPackages = ["cmd/herdr-auto-title"]` | Module layout | `cmd/` path still exists |
| Nothing pinned for `ps`/`lsof` (`internal/desktop/sessions_unix.go`) or `python3` (`internal/files/machine.go`) | `ps`/`lsof` come from the user's PATH; `python3 -c <embedded machine.py>` runs on a *connected remote machine* via herdr's `machine.exec` RPC, not locally | No new local `exec.Command` targets; `machine.py` still sent through `ExecMachine` rather than run locally |

### herdr-navigator (Rust, `buildRustPackage`)

| Workaround | Depends on | Check |
|---|---|---|
| `--replace-fail '"./target/release/herdr-navigator"'` in manifest → `$out/bin/herdr-navigator` | Every action/pane command is the cargo output path, quoted exactly so | Grep the new manifest for `target/release`; a renamed binary or a non-`--release` path breaks the build (intended). Built manifest has no `./target/` left |
| No `herdr` or `zoxide` in the package's runtime deps | Binary resolves herdr via `HERDR_BIN_PATH` (`src/herdr.rs`, falls back to bare `herdr`); `zoxide` is optional and only run from PATH (`src/sources.rs`) | Both still hold; any new `Command::new("<tool>")` in `src/` needs pinning or a note on why PATH is fine |
| Darwin `checkFlags` skips the three `/tmp`-keyed tests | Upstream tests insert the literal `"/tmp"` while lookups canonicalize to `/private/tmp` | Test names still exist (a stale `--skip` silently skips nothing); drop the skips once upstream uses a tempdir. Only verifiable on darwin |
| `[[build]]` (`cargo build --release`) left in manifest, never run | Same herdr install-only semantics as radar | As for radar |
| `users/features/herdr.nix`: `prefix+t` keybinding runs `${navigatorId}.open`; plugin config sets `[picker] check_updates = false` | Manifest action id `open`; `picker.check_updates` key in `src/config.rs` (self-update runs `herdr plugin install`, which can't write the read-only registry) | Action id and config key unchanged; no new self-update path that bypasses `check_updates` |

### herdr-radar (node scripts, `dontBuild`)

| Workaround | Depends on | Check |
|---|---|---|
| `--replace-fail '["node", '` in manifest | Every manifest command starts with bare `node` | Grep the new manifest for `["node",`; any other interpreter (`sh`, `bash`, `python`) needs its own pin |
| `cp -r bin lib dist shell package.json` | Those are all the runtime files | New top-level dirs/files (e.g. `assets/`) referenced by `lib/*.js` must be added |
| Font shipped as `<Base>-<sha256[0:8]>.ttf` under `share/fonts/truetype` | `lib/font.js` installed-font naming and the `dist/*.ttf` basename | Naming scheme and basename unchanged; if `dist/` gained a second `.ttf` that font.js installs, ship it too |
| `ranges` in the derivation (→ `passthru.codepointRanges`) | `RANGES` exported by `lib/font.js` | `checkPhase` runs node and fails the build if they differ; on failure copy the printed value into `ranges`. Feeds `ghostty` `font-codepoint-map` |
| `passthru.fontFamily` | Font's family name / what `install-font.js` writes to ghostty | Unchanged |
| `[[build]]` left in manifest, never run | herdr only runs `[[build]]` during `plugin install` | `grep -rn "plugin\.build" <herdr src>/src` hits only `src/cli/plugin.rs`; if the server/load path starts iterating it, strip it with `--replace` |
| `users/features/herdr.nix`: `configure.js --apply` at build time, `HERDR_RADAR_STATE` sandbox path rewritten with `sed`, `variant = "font"` / `follow_appearance = false` pin | `bin/configure.js` CLI, env var names, and the three marker-fenced blocks it writes; `lib/config.js` keys | Env var names and `--apply` flag unchanged; config keys still exist; the generated `config.toml` still contains exactly the expected blocks |

### herdr-worktreeinclude-local (bash script, `dontBuild`)

| Workaround | Depends on | Check |
|---|---|---|
| `--replace-fail '["bash", '` in manifest | Manifest command starts with bare `bash` | Unchanged |
| `--replace-fail 'export PATH="'` in script | The script has exactly that `export PATH="` line; tools it calls are `coreutils git grep sed jq` | Line still present (else `--replace-fail` breaks the build, which is intended); no new tools used |

The version is `<manifest version>-unstable-<date>`; if the manifest's
`version` field changed, update the leading part too.

## Herdr input: users/features/herdr.nix

Not a plugin, but the same class of coupling, and a `flake.lock` bump of
`herdr` can invalidate it. When the herdr input moved, check in the
`inputs.herdr` source:

- `plugins.json` fields (registry still needs only `plugin_id name version
  manifest_path plugin_root enabled`).
- `[[build]]` only runs at install time.
- `src/integration/assets/claude/herdr-agent-state.sh` still has the exact
  `command -v python3` and `python3 - <<'PY'` strings the `substitute` targets
  (a mismatch fails the eval, which is the point, but then re-derive).
- The opencode asset filenames.

## Build and inspect

In addition to the generic inspection of each plugin's `$out`:

```sh
cat "$out/herdr-plugin.toml"      # interpreters resolved to /nix/store/…; no bare node/bash
```

Then the generated herdr config, which runs radar's `configure.js` at build
time and is where a radar change most often surfaces:

```sh
nix build --no-write-lock-file --no-link --print-out-paths \
  'path:.#nixosConfigurations.joshua.config.home-manager.users.sadbeast.home.file.".config/herdr/config.toml".source'
cat <that path>   # three managed blocks present, state dir path rewritten (no $TMPDIR path)
```

If a plugin gained a `[[startup]]` or action command, run it once from the
store path with `plugin_root` as cwd to confirm the pinned interpreter and
PATH are sufficient (`cd "$out" && ./<cmd> --help` or similar).

## Key files

- `pkgs/herdr-*/default.nix`: one derivation per plugin; `$out` is the plugin root.
- `users/features/herdr.nix`: plugin registry, generated `config.toml`, font/ghostty wiring, herdr agent integrations.
- `flake.lock` `nodes.herdr`: the herdr version the plugins run under.
