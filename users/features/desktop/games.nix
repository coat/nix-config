{pkgs, ...}: {
  programs = {
    discord = {
      enable = true;
      # nixpkgs' discord wrapper rewrites settings.json (replacing HM's symlink
      # with a plain file) unless both SKIP_* keys are set; HM only sets HOST.
      settings.SKIP_MODULE_UPDATE = true;
    };

    retroarch = {
      enable = true;
      cores = {
        desmume.enable = true;
        mame.enable = true;
        # mame2003-plus.enable = true;
        # mame2016.enable = true;
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
      # fallout-ce
      # fceux
      # lutris
      shattered-pixel-dungeon
      tiled
      uxn
    ];
  };
}
