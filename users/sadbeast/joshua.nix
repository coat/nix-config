{
  imports = [./desktop-base.nix];

  wayland.windowManager.sway.config.output = {
    HDMI-A-1 = {
      resolution = "1920x1080";
      position = "0,0";
    };
    DVI-D-1 = {
      resolution = "1920x1080";
      position = "1920,0";
    };
  };
}
