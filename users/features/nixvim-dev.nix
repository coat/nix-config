{lib, ...}: {
  imports = [
    ./nixvim/cmp.nix
    ./nixvim/conform.nix
    ./nixvim/gitsigns.nix
    ./nixvim/lsp.nix
    ./nixvim/neotest.nix
    ./nixvim/todo-comments.nix
    ./nixvim/trouble.nix
  ];

  plugins = {
    lint.enable = true;
    treesitter.enable = true;
    ts-comments.enable = true;
  };
}
