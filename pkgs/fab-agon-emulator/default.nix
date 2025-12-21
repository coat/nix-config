{
  stdenv,
  lib,
  fetchurl,
}:
stdenv.mkDerivation {
  pname = "fab-agon-emulator";
  version = "0.9.96";

  dontBuild = true;

  meta = with lib; {
    description = "An emulator of the Agon Light, Agon Light 2, and Agon Console8 8-bit computers.";
    homepage = "https://github.com/tomm/fab-agon-emulator";
    license = licenses.gpl3;
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [binaryNativeCode];
  };

  src = fetchurl {
    url = "https://github.com/tomm/fab-agon-emulator/releases/download/0.9.96/fab-agon-emulator-v0.9.96-linux-x86_64.tar.bz2";
    sha256 = "sha256-hagPy9zsApJWXKfLtlb5+vu6xl9pV7J++kYMRG1P4PI=";
  };

  # unpackPhase = ''
  #   tar xf $src
  # '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp fab-agon-emulator $out/bin
    cp agon-cli-emulator $out/bin
    cp -r firmware $out
    cp -r sdcard $out

    runHook postInstall
  '';
}
