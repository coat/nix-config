{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nodejs,
}:
stdenvNoCC.mkDerivation rec {
  pname = "herdr-radar";
  version = "1.3.5";

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
    hash = "sha256-HD942wFSJ80v/m0XY+SSf+2gMbKgNOuILxvvCAlQL1w=";
  };

  dontBuild = true;

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
    # Codepoint ranges the icon font owns (lib/font.js RANGES), for terminal
    # symbol maps.
    fontFamily = "Herdr Agent Icons Max";
    codepointRanges = ["U+E1A0-U+E1B6" "U+E1C0-U+E1C5"];
  };
}
