{pkgs, lib, ...}: {
  imports = [
    # ../features/global.nix
  ../features/zsh.nix
  ../features/git.nix
  ../features/ssh.nix
  ];

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
      warn-dirty = false;
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "joypixels"
        ];
      joypixels.acceptLicense = true;
    };
  };

  home = let
    username = "vscode";
  in {
    username = username;
    homeDirectory = "/home/${username}";

    packages = with pkgs; [
      comma
      joypixels
      unzip
      zip
    ];

    stateVersion = "25.05";

    sessionVariables = {
      CODEARTIFACT_AUTH_CMD = "aws codeartifact get-authorization-token --domain andros --domain-owner 111491220182 --region us-east-2 --query authorizationToken --output text";
    };
  };

  programs = {
    git = {
      enable = true;

      extraConfig = {
        core.sshCommand = "ssh -i ~/.ssh/id_rsa -o IdentitiesOnly=yes";
      };
      userName = "Kent Smith";
      userEmail = "kent.smith@andros.co";
    };

    fd.enable = true;
    home-manager.enable = true;
    starship.enable = true;

    tmux = {
      enable = true;
      shortcut = "a";
      escapeTime = 0;

      plugins = with pkgs; [
        tmuxPlugins.better-mouse-mode
        tmuxPlugins.pain-control
      ];

      extraConfig = ''
        # https://old.reddit.com/r/tmux/comments/mesrci/tmux_2_doesnt_seem_to_use_256_colors/
        set -g default-terminal "xterm-256color"
        set -ga terminal-overrides ",*256col*:Tc"
        set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
        set-environment -g COLORTERM "truecolor"

        # Mouse works as expected
        set-option -g mouse on
        # easy-to-remember split pane commands
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"
      '';
    };

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
  };
}
