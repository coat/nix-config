{
  stdenv,
  lib,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "ez80asm";
  version = "2.3";

  meta = with lib; {
    description = "ez80 assembler, running natively on the Agon platform";
    homepage = "https://github.com/AgonPlatform/agon-ez80asm";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    mainProgram = "ez80asm";
    # maintainers = [ maintainers.sadbeast ];
  };

  src = fetchFromGitHub {
    owner = "AgonPlatform";
    repo = "agon-ez80asm";
    rev = "v${version}";
    hash = "sha256-BZ6kZHbd6BF1RRyLlFouL3l9WwIMg0LLMWrlS/5UidI=";
  };

  # Upstream's Makefile hardcodes CC=gcc and branches on `ifeq ($(CC),gcc)`,
  # which breaks in the darwin stdenv (CC is clang there, and the else branch
  # is the Windows/MSBuild path). Compile the same sources directly instead.
  # `src/*.c` is exactly what upstream's unix target builds.
  buildPhase = ''
    runHook preBuild
    mkdir -p bin
    $CC -DUNIX -O2 -DNDEBUG -Wall -Wno-unused-result -o bin/ez80asm src/*.c
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/ez80asm "$out/bin/ez80asm"
    runHook postInstall
  '';
}
