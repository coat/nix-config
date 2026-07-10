{
  lib,
  pkgs,
  ...
}: let
  identity = import ./identity.nix;
in {
  imports = [
    (import ../common/home-base.nix {
      inherit (identity) username realName email;
      homeDirectory = "/Users/${identity.username}";
      extraImports = [
        ../features/desktop/aerospace.nix
        ../features/desktop/dev.nix
        ../features/desktop/ghostty.nix
        ../features/desktop/qutebrowser.nix
        ../features/dev.nix
      ];
    })
  ];

  home = {
    packages = with pkgs; [
      _1password-cli
      colima
      foot-terminfo
      fzf
    ];

    # sessionVariables = {
    #   AWS_REGION = "us-east-1";
    #   AWS_PROFILE = "";
    # };
  };

  programs = {
    obsidian.enable = true;

    nixvim.plugins.obsidian.settings.workspaces = [
      {
        name = "work";
        path = "~/Documents/vault/work";
      }
    ];
  };
}
