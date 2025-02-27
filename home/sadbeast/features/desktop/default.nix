{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    # ./firefox.nix
    ./foot.nix
    ./ghostty.nix
    ./qutebrowser.nix
    ./sway.nix
    ./waybar.nix
  ];

  home = {
    packages = with pkgs; [
      galculator
      pavucontrol
      vlc
      waypipe
      wine
    ];
  };
}
