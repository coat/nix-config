{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./foot.nix
    ./ghostty.nix
    ./qutebrowser.nix
    ./sway.nix
    ./waybar.nix
  ];

  fonts.fontconfig.enable = true;

  programs.librewolf.enable = true;
  programs.librewolf.package = pkgs.librewolf-bin;
  programs.obsidian.enable = true;

  home = {
    packages = with pkgs; [
      # galculator
      gimp
      lagrange
      pavucontrol
      signal-desktop
      transmission_4
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

  programs.nixvim = {
    imports = [
      ../nixvim/obsidian.nix
    ];
  };

  gtk.enable = true;

  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "org.qutebrowser.qutebrowser.desktop";
        "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
        "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
      };
    };

    userDirs = let
      homeDir = config.home.homeDirectory;
    in {
      enable = true;
      createDirectories = false;

      desktop = "${homeDir}";
      documents = "${homeDir}/docs";
      download = "${homeDir}/downloads";
      pictures = "${homeDir}/pics";
    };
  };
}
