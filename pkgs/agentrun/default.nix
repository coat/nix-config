{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  fetchurl,
  makeWrapper,
  nodejs_24,
  nodejs-slim_24,
  git,
  go,
}: let
  # AgentRun's engines floor is 24.22.3, Node's November 2026 security
  # release (scripts/check-node.mjs and the CLI refuse anything older).
  # Bump nixpkgs' Node until nixpkgs catches up; the condition drops this
  # override by itself once it does.
  nodeFloor = "24.22.3";
  nodejs =
    if lib.versionOlder nodejs-slim_24.version nodeFloor
    then
      nodejs_24.override {
        nodejs-slim = nodejs-slim_24.overrideAttrs {
          version = nodeFloor;
          src = fetchurl {
            url = "https://nodejs.org/dist/v${nodeFloor}/node-v${nodeFloor}.tar.xz";
            sha256 = "48ca3aa8a9b02133356922ef4fc80200e00598c80a4ef446f7c39a459222593d";
          };
        };
      }
    else nodejs_24;

  version = "0.1.0-beta.47";

  src = fetchFromGitHub {
    owner = "Parcha-ai";
    repo = "agentrun";
    rev = "v${version}";
    hash = "sha256-KCni3nPqdwJoCt8cZFxQnAtgY37eKRL2z48pp6fYMcY=";
  };

  # The console (apps/console) is outside the npm workspaces, with its own
  # lockfile, so it needs its own offline cache.
  consoleDeps = fetchNpmDeps {
    name = "agentrun-console-${version}-npm-deps";
    src = "${src}/apps/console";
    hash = "sha256-L9a/n8gKrurR+mxJgXoMuZp7c/j4uFyGfNQQy+r9Qwg=";
  };
in
  buildNpmPackage {
    pname = "agentrun";
    inherit version src nodejs;

    npmDepsHash = "sha256-5XZigN2DTMMu2v+UwajHQ8QNsDlVrMr/FmPGj9cgoSE=";

    # Upstream's image installs with `npm ci --ignore-scripts`; no package's
    # install script is part of the supported build.
    npmFlags = ["--ignore-scripts"];

    nativeBuildInputs = [makeWrapper go];

    # The image build's order: console first (the server build copies its
    # dist into packages/serve/dist/console), then every workspace. The root
    # `npm run build` then finds the console current by its input hash.
    preBuild = ''
      cp -r ${consoleDeps} "$TMPDIR/console-cache"
      chmod -R u+w "$TMPDIR/console-cache"
      pushd apps/console
      npm ci --ignore-scripts --offline --no-audit --no-fund --cache "$TMPDIR/console-cache"
      patchShebangs node_modules
      npm run build
      popd
    '';

    # computerd: the daemon the Docker computer provider copies into each
    # computer (dist/computerd-linux-{amd64,arm64}). Static (CGO_ENABLED=0)
    # and stdlib-only (no go.sum), so it builds offline. Not built: phoned
    # (JDK + Android SDK), which only the phone provider pushes to phones.
    postBuild = ''
      test -f packages/serve/dist/console/index.html
      GOTOOLCHAIN=local GOCACHE="$TMPDIR/go-build" GOPATH="$TMPDIR/go" \
        npm run build:daemon -w @parcha/agentrun-computer
      test -x packages/computer/dist/computerd-linux-amd64
      test -x packages/computer/dist/computerd-linux-arm64
    '';

    # The server runs from the workspace tree as built, dev dependencies
    # included: the pi packages it loads are the workspace's devDependencies
    # (upstream: "Never `npm prune --omit=dev`"). Like the image, drop the
    # coding-agent CLIs; each harness installs its pinned CLI into
    # <data>/harnesses on first use.
    installPhase = ''
      runHook preInstall

      rm -rf apps \
        node_modules/@anthropic-ai/claude-agent-sdk node_modules/@anthropic-ai/claude-agent-sdk-* \
        node_modules/@anthropic-ai/claude-code node_modules/.bin/claude \
        node_modules/@openai/codex node_modules/@openai/codex-* node_modules/.bin/codex
      sh packages/serve/docker/image-check.sh .

      mkdir -p "$out/lib/agentrun"
      cp -r package.json node_modules packages "$out/lib/agentrun/"

      # The launcher hands secrets to the server over a pipe; it needs a
      # `node` on PATH, and harness installs need `npm` (Node's execPath is
      # nodejs-slim, which has none beside it). git is for agents' learning
      # folders and PR checkouts.
      makeWrapper "$out/lib/agentrun/packages/serve/launcher/agentrun-serve" "$out/bin/agentrun-serve" \
        --prefix PATH : ${lib.makeBinPath [nodejs git]}
      makeWrapper ${lib.getExe' nodejs "node"} "$out/bin/agentrun" \
        --add-flags "$out/lib/agentrun/packages/agentrun/bin/agentrun.mjs" \
        --prefix PATH : ${lib.makeBinPath [nodejs git]}

      runHook postInstall
    '';

    passthru = {inherit nodejs consoleDeps;};

    meta = {
      description = "Control plane, durable execution and learning loop around agent harnesses (Claude Code, Codex, OpenCode, pi)";
      homepage = "https://github.com/Parcha-ai/agentrun";
      license = lib.licenses.asl20;
      mainProgram = "agentrun";
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
    };
  }
