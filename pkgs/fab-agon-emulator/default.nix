{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchzip,
  pkg-config,
  makeWrapper,
  coreutils,
  sdl3,
  udev,
}:
let
  version = "1.2.6";
in

# Linux builds from source; macOS uses upstream's prebuilt binary (the only
# macOS architecture they publish is arm64).
if stdenv.hostPlatform.isDarwin
then
  stdenv.mkDerivation {
    pname = "fab-agon-emulator";
    inherit version;

    src = fetchzip {
      url = "https://github.com/tomm/fab-agon-emulator/releases/download/${version}/fab-agon-emulator-v${version}-macos-arm64.zip";
      hash = "sha256-xGrPcZJMpTuT0xGUxvsS+eDds3D9439ekMpPiEDQ/HA=";
    };

    nativeBuildInputs = [makeWrapper];

    # Upstream builds these without a PREFIX, so both binaries look for
    # firmware/ and sdcard/ relative to the CWD. Install them under
    # $out/share/fab-agon-emulator and wrap the binaries to cd there (and
    # seed a writable ~/.agon-sdcard, matching the Linux build). SDL3 is
    # linked via @executable_path, so libSDL3.0.dylib must stay in $out/bin.
    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/share/fab-agon-emulator
      install -m755 fab-agon-emulator agon-cli-emulator libSDL3.0.dylib $out/bin/
      cp -r firmware sdcard $out/share/fab-agon-emulator/
      install -Dm644 -t $out/share/licenses/fab-agon-emulator LICENSE THIRD-PARTY-LICENSES/*.txt

      for bin in fab-agon-emulator agon-cli-emulator; do
        wrapProgram $out/bin/$bin --run '
          case " $* " in
            *" --sdcard"*) ;;
            *)
              if [ ! -e "$HOME/.agon-sdcard" ]; then
                ${coreutils}/bin/cp -r --no-preserve=mode,ownership '"$out"'/share/fab-agon-emulator/sdcard "$HOME/.agon-sdcard"
                echo "fab-agon-emulator: created $HOME/.agon-sdcard from the bundled sdcard" >&2
              fi
              ;;
          esac
          cd '"$out"'/share/fab-agon-emulator'
      done

      runHook postInstall
    '';

    meta = with lib; {
      description = "An emulator of the Agon Light, Agon Light 2, and Agon Console8 8-bit computers.";
      homepage = "https://github.com/tomm/fab-agon-emulator";
      license = licenses.gpl3;
      platforms = ["aarch64-darwin"];
      sourceProvenance = with sourceTypes; [binaryNativeCode binaryFirmware];
      mainProgram = "fab-agon-emulator";
    };
  }
else
  rustPlatform.buildRustPackage rec {
    pname = "fab-agon-emulator";
    inherit version;

    meta = with lib; {
      description = "An emulator of the Agon Light, Agon Light 2, and Agon Console8 8-bit computers.";
      homepage = "https://github.com/tomm/fab-agon-emulator";
      license = licenses.gpl3;
      platforms = platforms.linux;
      # The eZ80 MOS images in firmware/ are committed prebuilt.
      sourceProvenance = with sourceTypes; [fromSource binaryFirmware];
      mainProgram = "fab-agon-emulator";
    };

    # Submodules: the VDP sources and the default sdcard (tomm/popup-mos).
    src = fetchFromGitHub {
      owner = "tomm";
      repo = "fab-agon-emulator";
      rev = version;
      fetchSubmodules = true;
      hash = "sha256-Gx7FIaqhjBz37z9SKUwtU4cLZVUuD4HOq82B5Uc080Y=";
    };

    # Cargo.lock pins `ez80` via a git dependency (tomm/ez80), which the legacy
    # fetchCargoTarball fetcher rejects. fetchCargoVendor handles git deps and is
    # already the default on nixpkgs >= 25.05; opting in explicitly keeps older
    # nixpkgs (24.05/24.11, where it's off by default) working too.
    useFetchCargoVendor = true;
    cargoHash = "sha256-PCs3jYmIhiYc+f6804QEc/+BAM56x1/xnPxjdypMYJc=";

    nativeBuildInputs = [pkg-config makeWrapper];
    buildInputs = [sdl3 udev];

    # PREFIX is baked in at compile time: firmware is looked up in
    # $PREFIX/share/fab-agon-emulator instead of ./firmware. FORCE silences
    # build.rs's "use make" guard.
    env = {
      PREFIX = placeholder "out";
      FORCE = "1";
    };

    # The VDP firmware is C++ shared objects, built by upstream's Makefile.
    preBuild = ''
      make -j$NIX_BUILD_CORES vdp
    '';

    cargoBuildFlags = ["-p" "fab-agon-emulator" "-p" "agon-cli-emulator"];
    cargoTestFlags = cargoBuildFlags;

    postInstall = ''
      share=$out/share/fab-agon-emulator
      install -Dm644 -t $share firmware/vdp_*.so firmware/mos_*.bin firmware/mos_*.map
      cp -r sdcard $share/sdcard
      rm -rf $share/sdcard/.git
      install -Dm644 -t $out/share/applications dist_scripts/io.github.tomm.fab_agon_emulator.desktop
      install -Dm644 -t $out/share/icons/hicolor/256x256/apps dist_scripts/io.github.tomm.fab_agon_emulator.png
      install -Dm644 -t $out/share/metainfo dist_scripts/io.github.tomm.fab_agon_emulator.metainfo.xml

      # Without --sdcard the emulator uses ~/.agon-sdcard if it exists, else
      # ./sdcard. Seed a writable ~/.agon-sdcard on first run so it works out
      # of the box; an existing one is never touched.
      wrapProgram $out/bin/fab-agon-emulator --run '
        case " $* " in
          *" --sdcard"*) ;;
          *)
            if [ ! -e "$HOME/.agon-sdcard" ]; then
              ${coreutils}/bin/cp -r --no-preserve=mode,ownership '"$share"'/sdcard "$HOME/.agon-sdcard"
              echo "fab-agon-emulator: created $HOME/.agon-sdcard from the bundled sdcard" >&2
            fi
            ;;
        esac
      '
    '';
  }
