{
  stdenv,
  lib,
  fetchurl,
}:
stdenv.mkDerivation {
  pname = "fab-agon-emulator";
  version = "1.1.0";

  dontBuild = true;

  meta = with lib; {
    description = "An emulator of the Agon Light, Agon Light 2, and Agon Console8 8-bit computers.";
    homepage = "https://github.com/tomm/fab-agon-emulator";
    license = licenses.gpl3;
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [binaryNativeCode];
  };

  src = fetchurl {
    url = "https://github.com/tomm/fab-agon-emulator/releases/download/1.1.0/fab-agon-emulator-v1.1.0-linux-x86_64.tar.bz2";
    sha256 = "sha256-7kmd7YaY9K6eduIQi3f6nv11rOclZ17VPdka8cV2VfY=";
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
