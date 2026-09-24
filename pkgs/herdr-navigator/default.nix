{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "herdr-navigator";
  version = "0.3.6";

  meta = with lib; {
    description = "Herdr plugin: fuzzy navigator across workspaces, agents, projects, sessions, remotes, directories and actions";
    homepage = "https://github.com/thanhdat77/herdr-navigator";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "herdr-navigator";
  };

  src = fetchFromGitHub {
    owner = "thanhdat77";
    repo = "herdr-navigator";
    rev = "v${version}";
    hash = "sha256-+xtBu4m2YenFH+W3Sv7atDvcsgChS5mKXgVgKomM768=";
  };

  cargoHash = "sha256-1fvQ8hyarP1WQwqIRvqKCkttwAMj3wGieue91/VNll8=";

  # Darwin-only upstream test-fixture bug. These three tests key
  # `path_to_workspaces` on the literal string "/tmp", but the lookup side
  # goes through `Entry::key()` → `canonical_str` → `fs::canonicalize`. On
  # darwin /tmp is a symlink to private/tmp, so the lookup key resolves to
  # "/private/tmp" and never matches what the test inserted. Linux has no
  # such symlink, which is why upstream CI is green. The shipped binary is
  # unaffected — it canonicalizes on both sides.
  # Re-check on each bump: drop this once upstream tests use a tempdir.
  checkFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "--skip=app::tests::source_specific_reuse_distinguishes_same_path_workspaces"
    "--skip=app::tests::close_target_matches_entry_kind"
    "--skip=sources::tests::persisted_workspace_kind_survives_label_changes_and_legacy_labels_migrate"
  ];

  # $out is the plugin_root. Every manifest command points at the cargo
  # output dir (./target/release/…); rewrite them to the installed binary so
  # nothing depends on cwd. `[[build]]` (cargo) is left in the manifest but
  # never runs: herdr only builds during `plugin install`. Herdr passes its
  # own path as HERDR_BIN_PATH to actions and panes, so the plugin does not
  # need `herdr` on PATH; `zoxide` is optional and only probed on PATH.
  postInstall = ''
    substitute herdr-plugin.toml "$out/herdr-plugin.toml" \
      --replace-fail '"./target/release/herdr-navigator"' '"${placeholder "out"}/bin/herdr-navigator"'
  '';

  passthru.herdrPlugin = {
    id = "herdr-navigator";
    name = "Herdr Navigator";
  };
}
