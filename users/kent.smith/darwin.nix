{pkgs, ...}: {
  imports = [
    ../common/home-base.nix
    ../features/desktop/aerospace.nix
    ../features/desktop/dev.nix
    ../features/desktop/ghostty.nix
    ../features/desktop/qutebrowser.nix
    ../features/dev.nix
  ];

  me = import ./identity.nix;

  home = {
    packages = with pkgs; [
      _1password-cli
      acli
      colima
      foot-terminfo
      fzf
      google-cloud-sdk
      gws
      ollama
      opencode
      rtk
    ];

    # sessionVariables = {
    #   AWS_REGION = "us-east-1";
    #   AWS_PROFILE = "";
    # };
  };

  programs = {
    obsidian = {
      enable = true;
      vaults.work.target = "Documents/vault/work";
    };

    nixvim.plugins.obsidian.settings.workspaces = [
      {
        name = "work";
        path = "~/Documents/vault/work";
      }
    ];
  };
}
