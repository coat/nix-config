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
      gimp
      lagrange
      pavucontrol
      qalculate-gtk
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

  programs = {
    nixvim = {
      imports = [
        ../nixvim/obsidian.nix
      ];
    };

    chromium.enable = true;
  };

  gtk.enable = true;

  xdg = {
    mimeApps.enable = true;

    userDirs = let
      homeDir = config.home.homeDirectory;
    in {
      enable = true;
      createDirectories = false;

      desktop = "${homeDir}";
      documents = "${homeDir}/docs";
      download = "${homeDir}/downloads";
      pictures = "${homeDir}/pics";

      setSessionVariables = false;
    };
  };
}
