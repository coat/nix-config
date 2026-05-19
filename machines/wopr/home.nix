{pkgs, ...}: {
  imports = [
    ../../users/sadbeast/desktop-home.nix
    ../../users/features/desktop/games.nix
  ];

  programs.bluetuith.enable = true;

  wayland.windowManager.sway.config.terminal = "${pkgs.foot}/bin/foot";
}
