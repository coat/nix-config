{
  stdenvNoCC,
  lib,
  fetchurl,
  ncurses,
}:
stdenvNoCC.mkDerivation rec {
  pname = "foot-terminfo";
  version = "1.27.0";

  src = fetchurl {
    url = "https://codeberg.org/dnkl/foot/raw/tag/${version}/foot.info";
    hash = "sha256-QKI1CKKrXJ6t+XnsY5tRgFRA0MCjIs/uVMm0jkVrikE=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ncurses];

  buildPhase = ''
    runHook preBuild
    substitute $src foot.info --replace-fail '@default_terminfo@' 'foot'
    mkdir -p $out/share/terminfo
    tic -x -o $out/share/terminfo foot.info
    runHook postBuild
  '';

  dontInstall = true;

  meta = with lib; {
    description = "Terminfo entries for the foot terminal emulator";
    homepage = "https://codeberg.org/dnkl/foot";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
