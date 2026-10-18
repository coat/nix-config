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
    homepage = "https://github.com/envenomator/agon-ez80asm";
    license = licenses.mit;
    platforms = platforms.linux;
    # maintainers = [ maintainers.sadbeast ];
  };

  src = fetchFromGitHub {
    owner = "envenomator";
    repo = "agon-ez80asm";
    rev = "v${version}";
    hash = "sha256-BZ6kZHbd6BF1RRyLlFouL3l9WwIMg0LLMWrlS/5UidI=";
  };

  installPhase = ''
    mkdir --parents "$out/bin"
    cp ./bin/ez80asm "$out/bin"
  '';
}
