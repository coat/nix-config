{
  stdenv,
  lib,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "ez80asm";
  version = "2.0";

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
    hash = "sha256-6NqhlTht5W8emXdGU+JeM/TcGo8GnRWmrKT6T4NGLVg=";
  };

  installPhase = ''
    mkdir --parents "$out/bin"
    cp ./bin/ez80asm "$out/bin"
  '';
}
