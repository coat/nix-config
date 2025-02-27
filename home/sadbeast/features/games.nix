{
  pkgs,
  config,
  ...
}: {
  home = {
    packages = with pkgs; [
      discord
      ez80asm
      fab-agon-emulator
      fallout-ce
      fceux
      lutris
      shattered-pixel-dungeon
      tiled
      (retroarch.withCores (cores:
        with cores; [
          mesen
          gambatte
        ]))
    ];
  };
}
