{overlays}: nixpkgsSrc: system:
import nixpkgsSrc {
  inherit system overlays;
  config.allowUnfree = true;
}
