{
  lib,
  overlays,
}: nixpkgsSrc: system:
import nixpkgsSrc {
  inherit system overlays;
  config = {
    allowUnfree = true;
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "copilot-language-server"
      ];
    allowInsecurePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "librewolf-bin"
        "librewolf-bin-unwrapped"
      ];
  };
}
