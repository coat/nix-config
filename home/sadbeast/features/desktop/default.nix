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

  fonts.fontconfig.enable = true;

  home = {
    packages = with pkgs; [
      galculator
      gimp
      pavucontrol
      vlc
      waypipe
      wine
    ];

    pointerCursor = {
      gtk.enable = true;
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 22;
    };
  };

  programs.librewolf.enable = true;

  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome-themes-extra;
      # name = "Adwaita-dark";
      name = "Adwaita";
    };
  };
}
