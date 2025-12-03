{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./git.nix
    ./gpg.nix
    ./nixvim
    ./pass.nix
    ./ssh.nix
    ./tmux.nix
    ./zsh.nix
  ];

  programs = {
    btop = {
      enable = true;
      settings = {
        vim_keys = true;
        clock_format = "";
      };
    };
    fd.enable = true;
    ripgrep.enable = true;
    starship.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      defaultCommand = "fd -H -E .git --type f";
      changeDirWidgetCommand = "fd --type d";
      fileWidgetCommand = "fd --type f";
      historyWidgetOptions = [
        "--sort"
        "--exact"
      ];
    };

    keychain = {
      enable = true;
      enableZshIntegration = true;
      keys = ["id_ed25519"];
      extraFlags = ["--quiet"];
    };
  };

  home = {
    packages = with pkgs; [
      comma
      home-manager
    ];
  };

  xdg.userDirs = let
    homeDir = config.home.homeDirectory;
  in {
    enable = true;
    createDirectories = false;

    desktop = "${homeDir}";
    documents = "${homeDir}/docs";
    download = "${homeDir}/downloads";
    pictures = "${homeDir}/pics";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
