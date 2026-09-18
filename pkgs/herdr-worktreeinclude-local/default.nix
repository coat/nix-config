{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bash,
  coreutils,
  git,
  gnugrep,
  gnused,
  jq,
}:
stdenvNoCC.mkDerivation {
  pname = "herdr-worktreeinclude-local";
  # No tags upstream; version is the manifest's, pinned to a commit.
  version = "0.1.0-unstable-2026-09-17";

  meta = with lib; {
    description = "Herdr plugin that copies gitignored files matching .worktreeinclude into new worktrees";
    homepage = "https://github.com/shved270189/herdr-worktreeinclude-local";
    license = licenses.mit;
    platforms = platforms.unix;
  };

  src = fetchFromGitHub {
    owner = "shved270189";
    repo = "herdr-worktreeinclude-local";
    rev = "6a6af2abbf355605d9a2e0c4b3d3fb6986f67524";
    hash = "sha256-ymy04KtN/doSYocNm3FuiBbCtq2rOt0Kbki83TUVp+M=";
  };

  dontBuild = true;

  # Herdr runs manifest commands as argv with plugin_root as cwd and the
  # server's environment. Pin the interpreter and put the script's tools on
  # PATH so it does not depend on what the server happened to inherit.
  installPhase = ''
    mkdir -p "$out"
    substitute herdr-plugin.toml "$out/herdr-plugin.toml" \
      --replace-fail '["bash", ' '["${bash}/bin/bash", '
    substitute copy-worktreeinclude.sh "$out/copy-worktreeinclude.sh" \
      --replace-fail 'export PATH="' 'export PATH="${lib.makeBinPath [coreutils git gnugrep gnused jq]}:'
    chmod +x "$out/copy-worktreeinclude.sh"
  '';

  passthru.herdrPlugin = {
    id = "herdr-worktreeinclude-local";
    name = "Worktree Include Local";
  };
}
