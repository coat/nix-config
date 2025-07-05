{
  config,
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      ### plugins installer
      gnumake
      unzip
      ### treesitter
      tree-sitter
      gcc
      ### to build nil_ls
      cargo
    ];
  };

  # home.file."${config.xdg.configHome}/nvim" = {
  #   source = ./nvim;
  #   recursive = true;
  # };
}
