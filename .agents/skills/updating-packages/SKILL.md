---
name: updating-packages
description: "Checks the custom packages in pkgs/ for upstream updates, bumps them, verifies they build, and audits whether each packaging workaround is still needed. Use when the user asks to update, bump, or check custom packages (including herdr plugins), asks whether a package patch/workaround is still necessary, or after the herdr flake input moves."
---

# Updating custom packages

The derivations in `pkgs/` are hand-packaged, and most carry workarounds
(`--replace-fail`, `postPatch`, hand-written `installPhase`, wrappers) that
couple them to specific upstream file names and contents. An update is not
"bump version + hash": every coupling must be re-checked against the new
source. Run this for every package in `pkgs/default.nix` unless the user
names some.

Package-specific facts live in two places, and both are part of this
procedure:

- **The comments in each `pkgs/<pkg>/default.nix`.** Every workaround there
  should say which upstream fact it depends on. If you add or re-derive one,
  write that comment too.
- **`references/herdr-plugins.md`** for `pkgs/herdr-*`. Read it before
  touching any herdr plugin, or when the `herdr` flake input moved. Those
  plugins are coupled to herdr's plugin loader and to
  `users/features/herdr.nix`, not just to their own upstream.

## 1. Inventory

For each package, record the pinned `version` and source, then the upstream
latest. `owner`/`repo` (or `url`) are in the fetcher:

```sh
gh api repos/<owner>/<repo>/releases/latest --jq .tag_name   # may 404 if no releases
gh api repos/<owner>/<repo>/tags --jq '.[0].name'
gh api repos/<owner>/<repo>/commits/HEAD --jq '.sha + " " + .commit.committer.date'  # untagged
```

Skip packages with no upstream (e.g. `pair-invite`, a local
`writeShellApplication`). If nothing is behind, report that and stop, unless
a flake input that a package or its consumer depends on moved (for herdr
plugins: see the reference).

## 2. Review the upstream diff before touching anything

```sh
gh api repos/<owner>/<repo>/compare/<old-rev>...<new-rev> \
  --jq '.commits[].commit.message | split("\n")[0]'
gh api repos/<owner>/<repo>/compare/<old-rev>...<new-rev> --jq '.files[] | "\(.status) \(.filename)"'
gh api repos/<owner>/<repo>/compare/<old-rev>...<new-rev> \
  --jq '.files[] | select(.filename == "<file>") | .patch'
```

The compare API stops at 250 commits and 300 files. When `.commits | length`
or `.files | length` hits that limit, the list is incomplete: prefetch both
revisions (`nix flake prefetch --json github:<owner>/<repo>/<rev>`, take
`.storePath`) and `diff` the two trees locally.

Cross the changed-file list against the package's couplings (step 4). Any hit
means that workaround must be re-derived, not just rebuilt. Also look for:

- **Lockfile changes** (`go.sum`, `Cargo.lock`, `package-lock.json`,
  `uv.lock`): the dependency hash must change.
- **Build system changes** (`Makefile`, `CMakeLists.txt`, `compile.sh`): they
  matter when the derivation bypasses or patches upstream's build.
- **New runtime commands**: grep the new source for process spawns
  (`exec.Command`, `Command::new`, `child_process`, `subprocess`,
  `#!/usr/bin/env`). A new tool needs pinning, or a note on why `PATH`
  is fine. A tool that runs on a *different* machine (over ssh or an RPC)
  can't be pinned; note it in the report instead.
- **New runtime files** (assets, data dirs) that a hand-written
  `installPhase` must now copy.

For packages without git history (`fetchurl` of a single file or binary),
diff the old and new file directly after prefetching both.

## 3. Bump

Pick the recipe for the package's source shape:

| Shape | Packages | Bump |
|---|---|---|
| Tagged GitHub release, `rev = "v${version}"` | ez80asm, romarr, herdr-* (tagged) | Edit `version`; `hash` from `nix flake prefetch --json github:<owner>/<repo>/<tag> \| jq -r .hash` |
| Untagged commit | agon-compression, herdr-worktreeinclude-local | Edit `rev`, `hash`, and the `<x>-unstable-<YYYY-MM-DD>` date in `version` (commit date) |
| `fetchurl` of a release file | foot-terminfo, agentrun (Node tarball) | `nix store prefetch-file --json <url> \| jq -r .hash` |
| Rolling binary assets | ai-beacon | Follow the command in its header comment. Assets are replaced in place, so hashes can break with no version change |
| Per-platform split | fab-agon-emulator | Linux builds from source (`fetchSubmodules = true`, plus `cargoHash`); darwin fetches a prebuilt zip with its own `hash`. Bump both |

Then refresh the language dependency hash if its lockfile changed:
`vendorHash` (`buildGoModule`), `cargoHash` (`buildRustPackage`),
`npmDepsHash` (`buildNpmPackage`). Set it to `lib.fakeHash`, build, and copy
the `got:` hash from the mismatch error. If the lockfile is unchanged the old
hash still holds, but a build confirms that either way. A package can have
more than one dependency cache (agentrun has a separate `fetchNpmDeps` for
the console, outside the npm workspaces), so check each one.

Some packages override a nixpkgs dependency until nixpkgs catches up
(agentrun's `nodeFloor`). Check whether nixpkgs now satisfies the floor
(`nix eval --raw nixpkgs#<dep>.version` against the flake's nixpkgs) and
whether upstream raised it (`engines` in `package.json`, a version check
script).

## 4. Audit the workarounds

Each workaround exists because of a specific upstream fact. Confirm the fact
still holds in the new source. If upstream fixed it, drop the workaround
rather than carrying it forever. Read the new source directly (the prefetch
`storePath`, or `nix build` and inspect).

Find the couplings without trusting any list:

- every `--replace-fail` / `--replace` / `substitute` string, and every
  `postPatch` / `patches` entry
- every path named in `installPhase` / `postInstall`, and every upstream file
  the derivation compiles directly instead of using upstream's build
  (ez80asm's `src/*.c`, agon-compression's `.c` files)
- every value copied from upstream into the derivation (baked version files,
  `passthru` values, platform lists)
- every reference to the package from consumers:
  `grep -rn '<pkg>' --include=*.nix . | grep -v '^./pkgs/'`
- every comment in the derivation that states an upstream fact ("upstream
  hardcodes…", "upstream builds these without a PREFIX…")

`--replace-fail` breaks the build when its target string disappears, which is
intended. A plain `--replace`, a `patches` hunk that now applies fuzzily,
or a test skip whose name no longer exists (it silently skips nothing) won't
break anything, so check those by hand.

For herdr plugins, also work through every table in
`references/herdr-plugins.md`.

## 5. Build and inspect

```sh
git add -N <any new files>
out=$(nix build --no-write-lock-file --no-link --print-out-paths 'path:.#<pkg>')
ls -R "$out" | head -40
```

A green build is not enough, because most workarounds are string
substitutions in files that aren't executed at build time. Inspect `$out`:
substituted files contain store paths and no bare interpreters, expected
files are present and leftovers absent. Then run the main binary once
(`--version` or `--help`) and confirm it reports the new version.

Never run a server or daemon binary to check it, not even with `--help`:
some ignore their arguments and start serving (romarr does). Read its usage
from the source instead, or exercise the code you need in the built package
without the entry point (e.g. `python -c 'from <pkg> import <mod>; …'` with
the wrapper's `PYTHONPATH`).

Then validate everything and format:

```sh
nix flake check --no-write-lock-file
nix fmt .
```

`nix flake check` on Linux skips darwin. For a package with a darwin path
(fab-agon-emulator's prebuilt zip, anything with `isDarwin`), also evaluate
the darwin host (command in `AGENTS.md`). The darwin hash itself is only
proven by a build on darwin; say so if you couldn't run one.

## 6. Report

For each package: old → new version (or "already latest"), the upstream
changes that mattered for packaging, and for each workaround whether it was
**kept** (fact still holds), **re-derived** (fact changed, what was updated)
or **dropped** (upstream fixed it). State that the change is evaluated/built
only, and that the user deploys with `clan machines update <host>` (herdr
plugins also need a herdr restart).

## Key files

- `pkgs/default.nix`: package index (what `nix build .#<pkg>` resolves).
- `pkgs/<pkg>/default.nix`: the derivation, and the comments explaining its workarounds.
- `references/herdr-plugins.md`: herdr plugin couplings and herdr-input checks.
