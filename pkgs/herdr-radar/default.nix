{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nodejs,
}: let
  # Codepoint ranges the icon font owns, as lib/font.js RANGES reports them.
  # Needed at eval time (ghostty's font-codepoint-map), so they are written
  # down here; the build fails if they drift from what the source computes.
  ranges = [
    ["E1A0" "E1B7"]
    ["E1C0" "E1C5"]
  ];
in
  stdenvNoCC.mkDerivation rec {
    pname = "herdr-radar";
    version = "1.3.12";

    meta = with lib; {
      description = "Herdr plugin: vendor logos, lifecycle glyphs and workspace grouping for the sidebar";
      homepage = "https://github.com/hhdebb/herdr-radar";
      license = licenses.mit;
      platforms = platforms.unix;
    };

    src = fetchFromGitHub {
      owner = "hhdebb";
      repo = "herdr-radar";
      rev = "v${version}";
      hash = "sha256-Ki9L3SsohzKIA8R5gkXfh4njCxdjFI3S0hLHBbV8mZg=";
    };

    nativeBuildInputs = [nodejs];

    dontBuild = true;

    doCheck = true;
    checkPhase = ''
      runHook preCheck
      expected=${lib.escapeShellArg (builtins.toJSON ranges)}
      actual=$(node -e 'console.log(JSON.stringify(require("./lib/font").RANGES))')
      if [ "$actual" != "$expected" ]; then
        echo "lib/font.js RANGES is $actual but this derivation says $expected; update \`ranges\`" >&2
        exit 1
      fi
      runHook postCheck
    '';

    # Plain node scripts, no npm dependencies at runtime. $out is the plugin
    # root; the manifest's `node` is pinned to the store so the herdr server
    # does not need node on PATH. `[[build]]` (bin/setup.js) is left in the
    # manifest but never runs: herdr only builds during `plugin install`, and
    # everything it would do is done declaratively in users/features/herdr.nix.
    installPhase = ''
      mkdir -p "$out/share/fonts/truetype"
      cp -r bin lib dist shell package.json "$out/"
      substitute herdr-plugin.toml "$out/herdr-plugin.toml" \
        --replace-fail '["node", ' '["${nodejs}/bin/node", '

      # lib/font.js looks for <BASENAME>-<first 8 hex of sha256>.ttf in the
      # user font dir; ship it under that name so it counts as installed.
      font=dist/HerdrAgentIconsMax-Regular.ttf
      hash=$(sha256sum "$font" | cut -c1-8)
      cp "$font" "$out/share/fonts/truetype/HerdrAgentIconsMax-$hash.ttf"
    '';

    passthru = {
      herdrPlugin = {
        id = "hhdebb.herdr-radar";
        name = "Herdr Radar";
      };
      # For terminal symbol maps (ghostty font-codepoint-map).
      fontFamily = "Herdr Agent Icons Max";
      codepointRanges = map (r: "U+${builtins.elemAt r 0}-U+${builtins.elemAt r 1}") ranges;
    };
  }
