{pkgs, ...}: {
  programs = {
    discord.enable = true;

    retroarch = {
      enable = true;
      cores = {
        desmume.enable = true;
        mame.enable = true;
        mesen.enable = true;
        mgba.enable = true;
        mupen64plus.enable = true;
        sameboy.enable = true;
        snes9x.enable = true;
      };
    };
  };

  home = {
    packages = with pkgs; [
      ez80asm
      fab-agon-emulator
      # fallout-ce
      fceux
      # lutris
      shattered-pixel-dungeon
      tiled
      uxn
    ];
  };
}
