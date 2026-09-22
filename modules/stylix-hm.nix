{
  lib,
  options,
  ...
}: {
  config = lib.optionalAttrs (options ? stylix) {
    stylix.targets.rofi.enable = false;
  };
}
