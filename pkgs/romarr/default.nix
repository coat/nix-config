{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  python3,
  libarchive,
}:
stdenv.mkDerivation rec {
  pname = "romarr";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "BlizzHacker";
    repo = "romarr";
    rev = "v${version}";
    hash = "sha256-kEc7Y3DsZ5d3bMJGJeu5EGrPxQQ3CXWahrUjZg+lTMg=";
  };

  nativeBuildInputs = [makeWrapper];

  installPhase = let
    # requests is ROMarr's one hard dependency (stdlib otherwise; playwright,
    # cryptography, rom_hub and pyseccomp are all optional lazy imports). The
    # buildEnv from `withPackages` symlinks requests and its transitive deps
    # into a single site-packages tree.
    py = python3.withPackages (ps: [ps.requests]);
  in ''
    runHook preInstall
    mkdir -p "$out/lib"
    cp -r romarr "$out/lib/romarr"

    # Bake the version: romarr/version.py reads romarr/_version.py (exactly
    # what the upstream Dockerfile does) so the update check reports a real
    # number instead of "unknown".
    printf '__version__ = "%s"\n' "${version}" > "$out/lib/romarr/_version.py"

    makeWrapper "${py}/bin/python" "$out/bin/romarr" \
      --set PYTHONPATH "$out/lib:${py}/${python3.sitePackages}" \
      --set PYTHONDONTWRITEBYTECODE 1 \
      --prefix PATH : "${libarchive}/bin" \
      --add-flags "-m romarr"
    runHook postInstall
  '';

  meta = with lib; {
    description = "The *arr for games: find, verify and organize your game library";
    homepage = "https://github.com/BlizzHacker/romarr";
    license = licenses.mit;
    mainProgram = "romarr";
    platforms = platforms.linux;
  };
}
