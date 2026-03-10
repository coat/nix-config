{pkgs, ...}: {
  imports = [
    ./desktop-base.nix
    ../features/desktop/games.nix
  ];

  programs.bluetuith.enable = true;

  wayland.windowManager.sway.config.terminal = "${pkgs.foot}/bin/foot";
}
