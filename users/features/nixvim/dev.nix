{
  programs.nixvim = {
    imports = [
      ./amp.nix
      ./cmp.nix
      ./conform.nix
      ./dap.nix
      ./gitsigns.nix
      ./lsp.nix
      ./neotest.nix
      ./todo-comments.nix
      ./trouble.nix
    ];

    plugins = {
      lint.enable = true;
      treesitter.enable = true;
      ts-comments.enable = true;
    };
  };
}
