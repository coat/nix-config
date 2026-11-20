{
  lib,
  stdenvNoCC,
  fetchurl,
}: let
  # Upstream publishes no source, only binaries on the rolling `snapshot`
  # pre-release. Every upstream build replaces those assets in place, so these
  # hashes break whenever it rebuilds: bump version + hashes from
  #   gh api repos/manusa/ai-beacon/releases --jq '.[].assets[] | .name+" "+.digest'
  # and `ai-beacon version` on the new binary.
  hashes = {
    x86_64-linux = "sha256-1wnyV7wUSt53HSBuzmSHdV6jAywBi42bSJl+Df+9oBg=";
    aarch64-linux = "sha256-CafTQo+tvsSXJtHZy2m4AfejA+mVBLj6itN+LeoLk0k=";
    x86_64-darwin = "sha256-je8ogvwRwxov6BZwY+VS1tj52MQLJ4qEWGzFEQfkKy0=";
    aarch64-darwin = "sha256-oRyy8SpliktHIVlwENSl9KwkhQBWBwXRlQv8o8bhykU=";
  };
  platform = stdenvNoCC.hostPlatform;
  goos = platform.parsed.kernel.name;
  goarch =
    if platform.isx86_64
    then "amd64"
    else "arm64";
in
  stdenvNoCC.mkDerivation {
    pname = "ai-beacon";
    version = "0.0.0-snapshot.20261119061114";

    src = fetchurl {
      url = "https://github.com/manusa/ai-beacon/releases/download/snapshot/ai-beacon-${goos}-${goarch}";
      hash = hashes.${platform.system};
    };

    dontUnpack = true;

    # Go binaries: static on Linux, only system frameworks on darwin.
    installPhase = ''
      runHook preInstall
      install -Dm755 "$src" "$out/bin/ai-beacon"
      runHook postInstall
    '';

    meta = with lib; {
      description = "Web dashboard for monitoring and orchestrating AI coding agents across devices";
      homepage = "https://github.com/manusa/ai-beacon";
      license = licenses.asl20;
      sourceProvenance = [sourceTypes.binaryNativeCode];
      mainProgram = "ai-beacon";
      platforms = builtins.attrNames hashes;
    };
  }
