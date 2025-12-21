{
  imports = [
    ./desktop-base.nix
    ../features/desktop/games.nix
  ];

  wayland.windowManager.sway.config = {
    output = {
      HDMI-A-1 = {
        resolution = "1920x1080";
        position = "0,0";
      };
      DVI-D-1 = {
        resolution = "1920x1080";
        position = "1920,0";
      };
    };

    input = {
      "8746:43:ILITEK_ILITEK_Multi-Touch" = {
        map_to_output = "HDMI-A-1";
      };
    };
  };
}
