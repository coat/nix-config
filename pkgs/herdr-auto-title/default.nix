{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "herdr-auto-title";
  version = "0.7.0";

  meta = with lib; {
    description = "Herdr plugin that automatically generates contextual tab titles";
    homepage = "https://github.com/kryptamine/herdr-auto-title";
    license = licenses.mit;
    platforms = platforms.unix;
  };

  src = fetchFromGitHub {
    owner = "kryptamine";
    repo = "herdr-auto-title";
    rev = "v${version}";
    hash = "sha256-Zj50p032D8q6jnNpr9ipT+/ek2hMTA3UT5AgaWGOc3g=";
  };

  vendorHash = "sha256-QxFp1b7pf7bn3Hh0hyaj8ke5Z61N+WwjhHt3pFiapTs=";

  subPackages = ["cmd/herdr-auto-title"];

  # Herdr runs `[[startup]]` commands with plugin_root as cwd, so the manifest
  # and binary must live side by side, exactly as `herdr plugin install` lays
  # them out. $out is the plugin_root.
  postInstall = ''
    mv "$out/bin/herdr-auto-title" "$out/herdr-auto-title"
    rmdir "$out/bin"
    cp "$src/herdr-plugin.toml" "$out/herdr-plugin.toml"
  '';

  # Consumed by users/features/herdr.nix to generate herdr's plugins.json.
  passthru.herdrPlugin = {
    id = "herdr.auto-title";
    name = "Auto Title";
  };
}
