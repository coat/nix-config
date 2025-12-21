{
  inputs,
  config,
  pkgs,
  ...
}: let
  mkDotfilesSymlink = link: {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/nix-config/${link}";
    force = true;
  };
in {
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      ### plugins installer
      gnumake
      unzip
      ### treesitter
      tree-sitter
      gcc
    ];
  };

  xdg.configFile."nvim" = mkDotfilesSymlink "home/sadbeast/features/nvim";
}
