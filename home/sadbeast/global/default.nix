{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default
    inputs.impermanence.nixosModules.home-manager.impermanence

    inputs.nix-index-database.hmModules.nix-index

    # You can also split up your configuration and import pieces of it here:
    ../features/git.nix
    ../features/gpg.nix
    ../features/nvim.nix
    ../features/pass.nix
    ../features/ssh.nix
    ../features/vim.nix
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

  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];

    config = {
      allowUnfree = true;
      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "joypixels"
        ];
      joypixels.acceptLicense = true;
    };
  };

  home = {
    username = "sadbeast";
    homeDirectory = "/home/${config.home.username}";
  };

  programs = {
    # browserpass = {
    #   enable = true;
    #   browsers = [ "firefox" ];
    # };

    btop = {
      enable = true;
      settings = {
        vim_keys = true;
        clock_format = "";
      };
    };

    fd.enable = true;

    gpg.enable = true;
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

    keychain = {
      enable = true;
      enableZshIntegration = true;
      keys = ["id_ed25519"];
      extraFlags = ["--quiet"];
    };
  };

  home = {
    packages = with pkgs; [
      joypixels
      sops
      unzip
      uxn
      zip
    ];

    # persistence = {
    #   "${config.home.homeDirectory}" = {
    #     directories = [
    #       {
    #         directory = "docs";
    #         method = "symlink";
    #       }
    #       {
    #         directory = "projects";
    #         method = "symlink";
    #       }
    #       {
    #         directory = ".local/share/qutebrowser";
    #         method = "symlink";
    #       }
    #       {
    #         directory = ".local/share/vim-lsp-settings";
    #         method = "symlink";
    #       }
    #       ".password-store"
    #       ".local/share/direnv"
    #       ".local/share/zsh"
    #       ".gnupg"
    #       ".ssh"
    #     ];
    #     allowOther = true;
    #   };
    # };
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

  xdg.mimeApps = {
    enable = true;

    defaultApplications = lib.mkDefault {
      "text/html" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/about" = "org.qutebrowser.qutebrowser.desktop";
      "x-scheme-handler/unknown" = "org.qutebrowser.qutebrowser.desktop";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
