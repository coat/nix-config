{
  fetchurl,
  makeWrapper,
  dpkg,
  stdenv,
  lib,
  pkgs,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pop";
  version = "8.0.21";

  # dontBuild = true;
  # dontConfigure = true;
  dontStrip = true;

  meta = with lib; {
    description = "Pop - Screen sharing for remote teams";
    homepage = "https://pop.com";
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    license = licenses.unfree;
    platforms = platforms.linux;
    mainProgram = "pop";
  };

  src = fetchurl {
    url = "https://download.pop.com/desktop-app/linux/8.0.21/pop_8.0.21_amd64.deb";
    sha256 = "1n9h1vn3scvpwv0vmkpygi6rqznzs0vj6y6hyzh12qgv67zwm75v";
  };
  nativeBuildInputs = [dpkg makeWrapper];

  buildInputs = with pkgs;
    [
      alsa-lib
      atk
      cairo
      cups
      dbus
      expat
      gdk-pixbuf
      glib
      gtk3
      ffmpeg
      libdrm
      libxkbcommon
      mesa
      nspr
      nss
      pango
    ]
    ++ (with pkgs.xorg; [
      libX11
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libXtst
      libXrandr
      libxcb
      libxshmfence
    ]);

  # ${dpkg}/bin/dpkg -x $src $out
  unpackPhase = ''
    dpkg --fsys-tarfile $src | tar --extract
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    mv usr/* $out

    wrapProgram $out/lib/pop/Pop \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" \


    runHook postInstall
  '';
})
