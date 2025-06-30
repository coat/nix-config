{
  inputs,
  lib,
  config,
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
    ../../features/global.nix
    ../../features/git.nix
    ../../features/gpg.nix
    ../../features/nvim.nix
    ../../features/pass.nix
    ../../features/ssh.nix
    ../features/vim.nix
    ../../features/zsh.nix
    ../../features/devcontainers.nix
  ];

  home = {
    username = "sadbeast";
    homeDirectory = "/home/${config.home.username}";
  };

  programs = {
    btop = {
      enable = true;
      settings = {
        vim_keys = true;
        clock_format = "";
      };
    };
  };

  home = {
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
