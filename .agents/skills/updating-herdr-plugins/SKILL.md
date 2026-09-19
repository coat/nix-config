---
name: updating-herdr-plugins
description: "Checks the nix-packaged herdr plugins (pkgs/herdr-*) for upstream updates, bumps them, verifies they build, and audits whether each packaging workaround is still needed. Use when the user asks to update, bump, or check herdr plugins, or asks whether a herdr plugin patch/workaround is still necessary."
---

# Updating herdr plugins

The herdr plugins in `pkgs/herdr-*` are packaged by hand rather than via
`herdr plugin install`, so each derivation carries workarounds that couple it
to specific upstream file names, manifest strings and script contents. An
update is not "bump version + hash": every coupling must be re-checked against
the new source, and the consumer (`users/features/herdr.nix`) re-verified.

Run this for all plugins unless the user names one.

## 1. Inventory

For each `pkgs/herdr-*/default.nix`, record the pinned version and source
(`rev` is a tag `v${version}` or a bare commit), then the upstream latest:

```sh
# Tagged releases (auto-title, radar)
gh api repos/<owner>/<repo>/releases/latest --jq .tag_name   # may 404 if no releases
gh api repos/<owner>/<repo>/tags --jq '.[0].name'
# Untagged (worktreeinclude-local: version is `<manifest>-unstable-<date>` + commit)
gh api repos/<owner>/<repo>/commits/HEAD --jq '.sha + " " + .commit.committer.date'
```

`owner`/`repo` are in each derivation's `fetchFromGitHub`. Also note the
locked herdr input, since plugin-loading semantics live there:

```sh
jq -r '.nodes.herdr.locked | "\(.rev[0:12]) \(.lastModified | todate)"' flake.lock
```

If nothing is behind, report that and stop (still do step 4 if the herdr
input moved since the last plugin bump — `git log -1 --format=%cd -- pkgs/herdr-*`).

## 2. Review the upstream diff before touching anything

```sh
gh api repos/<owner>/<repo>/compare/<old-rev>...<new-rev> \
  --jq '.commits[].commit.message | split("\n")[0]'
gh api repos/<owner>/<repo>/compare/<old-rev>...<new-rev> --jq '.files[].filename'
```

Cross the changed-file list against the plugin's **coupling list** (step 4).
Any hit means the corresponding workaround must be re-derived, not just
rebuilt. Read the actual patch for those files:

```sh
gh api repos/<owner>/<repo>/compare/<old-rev>...<new-rev> \
  --jq '.files[] | select(.filename == "<file>") | .patch'
```

Also check `herdr-plugin.toml` for a new minimum herdr version or new
`[[startup]]`/`[[build]]`/action entries: new commands mean new interpreters
or tools that need pinning the same way the existing ones are.

## 3. Bump

Edit `version`, `rev` (if a bare commit) and `hash`:

```sh
nix flake prefetch --json github:<owner>/<repo>/<tag-or-rev> | jq -r .hash
```

For `buildGoModule` packages (auto-title), also refresh `vendorHash` when
`go.mod`/`go.sum` changed: set it to `lib.fakeHash`, build, and copy the
`got:` hash from the mismatch error. If `go.sum` is unchanged the old
`vendorHash` still holds, but a build confirms that either way.

For untagged packages, update the date suffix in `version` and, if the
manifest's `version` field changed, the leading part too.

## 4. Audit the workarounds

Each workaround exists because of a specific upstream fact. For every entry,
confirm the fact still holds in the new source; if upstream fixed it, drop
the workaround rather than carrying it forever. Read the new source directly
(`nix build` then inspect `result/`, or `gh api repos/<owner>/<repo>/contents/<path>?ref=<rev>`).

How to find the couplings without trusting this list: every
`--replace-fail` string, every path named in `installPhase`/`postInstall`,
every `passthru` value copied from upstream source, and everything
`users/features/herdr.nix` references under `${p}/…` or via `passthru`.

### herdr-auto-title (Go, `subPackages`)

| Workaround | Depends on | Check |
|---|---|---|
| `mv $out/bin/<name> $out/<name>`; `cp $src/herdr-plugin.toml` | Manifest `[[startup]]` command is a relative `./herdr-auto-title`; herdr runs it with `plugin_root` as cwd | Manifest command path unchanged; binary name unchanged; no new files the manifest references |
| `subPackages = ["cmd/herdr-auto-title"]` | Module layout | `cmd/` path still exists |

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

### Shared: users/features/herdr.nix vs the herdr input

Not a plugin, but the same class of coupling, and a `flake.lock` bump of
`herdr` can invalidate it. When the herdr input moved, check in
`inputs.herdr` source:

- `plugins.json` fields (registry still needs only `plugin_id name version
  manifest_path plugin_root enabled`).
- `[[build]]` only runs at install time.
- `src/integration/assets/claude/herdr-agent-state.sh` still has the exact
  `command -v python3` and `python3 - <<'PY'` strings the `substitute` targets
  (a mismatch fails the eval, which is the point — but then re-derive).
- The opencode asset filenames.

## 5. Build and inspect

Build each changed package and the consumer derivation:

```sh
nix build --no-write-lock-file --no-link --print-out-paths 'path:.#<pkg>'
```

Then inspect `$out` — a successful build is not enough because most
workarounds are string substitutions on files that are never executed at
build time:

```sh
out=$(nix build --no-write-lock-file --no-link --print-out-paths 'path:.#<pkg>')
cat "$out/herdr-plugin.toml"      # interpreters resolved to /nix/store/…; no bare node/bash
ls -R "$out" | head -40           # no leftover bin/ (auto-title); expected files present
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

Finally, `nix fmt`.

## 6. Report

For each plugin: old → new version, the upstream changes that mattered for
packaging, and for each workaround whether it was **kept** (fact still
holds), **re-derived** (fact changed, what was updated), or **dropped**
(upstream fixed it). State that the change is evaluated/built only — the
user deploys with `clan machines update <host>` — and that the updated
plugin takes effect after herdr restarts.

## Key files

- `pkgs/herdr-*/default.nix` — one derivation per plugin; `$out` is the plugin root.
- `pkgs/default.nix` — package index (also what `nix build .#<pkg>` resolves).
- `users/features/herdr.nix` — plugin registry, generated `config.toml`, font/ghostty wiring, herdr agent integrations.
- `flake.lock` `nodes.herdr` — the herdr version the plugins run under.
