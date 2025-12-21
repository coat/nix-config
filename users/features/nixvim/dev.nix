{pkgs, ...}: {
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
      treesitter = {
        enable = true;

        settings = {
          highlight.enable = true;
          indent.enable = true;
        };

        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          bash
          json
          lua
          markdown
          nix
          regex
          ruby
          toml
          vim
          vimdoc
          xml
          yaml
        ];
      };

      ts-comments.enable = true;
    };
  };
}
