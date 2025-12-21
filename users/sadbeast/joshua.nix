{
  inputs,
  config,
  ...
}: {
  imports = [
    ./home.nix
    ../features/desktop
    ../features/desktop/games.nix
    ../features/dev.nix
  ];

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
