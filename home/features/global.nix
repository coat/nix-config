{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../features/dev.nix
    ../features/git.nix
    # ../features/nvim.nix
    ../features/pass.nix
    ../features/ssh.nix
    ../features/zsh.nix
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

  home = {
    packages = with pkgs; [
      comma
      obsidian
      sops
      unzip
      zip
    ];
  };

  programs = {
    git = {
      enable = true;

      settings.core.sshCommand = "ssh -i ~/.ssh/id_rsa -o IdentitiesOnly=yes";
    };

    fd.enable = true;
    home-manager.enable = true;
    ripgrep.enable = true;
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

    gpg = {
      enable = true;
      settings = {
        trust-model = "tofu+pgp";
      };
    };

    keychain = {
      enable = true;
      enableZshIntegration = true;
      keys = ["id_ed25519"];
      extraFlags = ["--quiet"];
    };

    rmpc.enable = true;
  };
}