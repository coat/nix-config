{
  stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
  sdl3,
}:
stdenv.mkDerivation rec {
  pname = "fab-agon-emulator";
  version = "1.1.0";

  meta = with lib; {
    description = "An emulator of the Agon Light, Agon Light 2, and Agon Console8 8-bit computers.";
    homepage = "https://github.com/tomm/fab-agon-emulator";
    license = licenses.gpl3;
    platforms = ["x86_64-linux"];
    sourceProvenance = with sourceTypes; [binaryNativeCode];
  };

  src = fetchurl {
    url = "https://github.com/tomm/fab-agon-emulator/releases/download/${version}/fab-agon-emulator-v${version}-linux-x86_64.tar.bz2";
    hash = "sha256-7kmd7YaY9K6eduIQi3f6nv11rOclZ17VPdka8cV2VfY=";
  };

  # Prebuilt generic-linux binaries: patch the interpreter and rpath so they
  # run on NixOS.
  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [sdl3 stdenv.cc.cc.lib];

  dontBuild = true;

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
