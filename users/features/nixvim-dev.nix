{
  programs.nixvim = {
    imports = [
      ./nixvim/amp.nix
      ./nixvim/cmp.nix
      ./nixvim/conform.nix
      ./nixvim/dap.nix
      ./nixvim/gitsigns.nix
      ./nixvim/lsp.nix
      ./nixvim/neotest.nix
      ./nixvim/obsidian.nix
      ./nixvim/todo-comments.nix
      ./nixvim/trouble.nix
    ];

    plugins = {
      lint.enable = true;
      treesitter.enable = true;
      ts-comments.enable = true;
    };
  };
}
