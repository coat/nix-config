{
  stdenv,
  lib,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "agon-compression";
  # Upstream has no tags or releases.
  version = "0-unstable-2024-03-26";

  meta = with lib; {
    description = "TurboVega-style file compressor and decompressor for the Agon platform";
    homepage = "https://github.com/TurboVega/agon_compression";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "agon-compress";
  };

  src = fetchFromGitHub {
    owner = "TurboVega";
    repo = "agon_compression";
    rev = "06fc402f843715b988b369ab5f932e06c5c0f756";
    hash = "sha256-8ShmXWlckLNx6zfWOakrEzqyvbVfcVEQ0z+lmF9beg4=";
  };

  # Upstream ships prebuilt Linux binaries named compress/decompress and a
  # compile.sh that hardcodes gcc. Build from the .c files with $CC instead,
  # and prefix the names: plain `compress`/`decompress` are too generic.
  buildPhase = ''
    runHook preBuild
    $CC -O2 -o agon-compress compress.c
    $CC -O2 -o agon-decompress decompress.c
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin agon-compress agon-decompress
    runHook postInstall
  '';
}
