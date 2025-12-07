{pkgs, ...}: {
  imports = [
    ./git.nix
    ./nixvim
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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
