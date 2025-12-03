{pkgs, ...}: {
  imports = [
    ./foot.nix
    ./ghostty.nix
    ./qutebrowser.nix
    ./sway.nix
    ./waybar.nix
  ];

  fonts.fontconfig.enable = true;

  programs.librewolf.enable = true;

  home = {
    packages = with pkgs; [
      galculator
      gimp
      lagrange
      pavucontrol
      vlc
      waypipe
    ];

    pointerCursor = {
      gtk.enable = true;
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 22;
    };
  };

  gtk.enable = true;
}
