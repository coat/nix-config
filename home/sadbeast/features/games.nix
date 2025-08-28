{
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
      discord
      ez80asm
      fab-agon-emulator
      # fallout-ce
      fceux
      lutris

      (retroarch.withCores (cores:
        with cores; [
          desmume
          mame
          mesen
          mgba
          mupen64plus
          sameboy
          snes9x
        ]))

      shattered-pixel-dungeon
      tiled
      uxn
    ];
  };
}
