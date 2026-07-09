{pkgs, ...}: {
  programs.nixvim = {
    imports = [
      ./cmp.nix
      ./conform.nix
      ./dap.nix
      ./gitsigns.nix
      ./lsp.nix
      ./neotest.nix
      ./opencode.nix
      ./todo-comments.nix
      ./trouble.nix
    ];

    plugins = {
      # Load per-directory direnv environments (e.g. devenv's GEM_HOME/PATH) so
      # project-local LSPs like ruby-lsp can find their gems. Fires `User DirenvLoaded`.
      direnv.enable = true;

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
