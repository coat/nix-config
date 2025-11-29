{lib, ...}: {
  plugins.conform-nvim = {
    enable = true;
    settings = {
      default_format_opts = {
        timeout_ms = 3000;
        async = false;
        quiet = false;
        lsp_format = "fallback";
      };
      formatters_by_ft = {
        lua = ["stylua"];
        fish = ["fish_indent"];
        sh = ["shfmt"];
        nix = ["alejandra"];
      };
      formatters = {
        injected = {
          options = {
            ignore_errors = true;
          };
        };
      };
      format_on_save = lib.nixvim.mkRaw ''
        function(bufnr)
          if vim.g.autoformat == nil then vim.g.autoformat = true end
          if not vim.g.autoformat then return end
          return { timeout_ms = 3000, lsp_format = "fallback" }
        end
      '';
    };
  };

  keymaps = [
    {
      mode = ["n" "x"];
      key = "<leader>cF";
      action = lib.nixvim.mkRaw ''
        function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end
      '';
      options.desc = "Format Injected Langs";
    }
  ];
}
