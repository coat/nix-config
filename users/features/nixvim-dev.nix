{lib, ...}: {
  imports = [
    ./nixvim/cmp.nix
    ./nixvim/gitsigns.nix
    ./nixvim/lsp.nix
    ./nixvim/todo-comments.nix
    ./nixvim/trouble.nix
  ];

  plugins = {
    lint.enable = true;
    treesitter.enable = true;
    ts-comments.enable = true;
  };
}
