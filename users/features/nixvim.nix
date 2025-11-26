{lib, ...}: {
  enable = true;
  # You can use lib.nixvim in your config
  # fooOption = lib.nixvim.mkRaw "print('hello')";

  colorschemes.base16 = {
    enable = true;
    # https://github.com/tinted-theming/tinted-vim/blob/483154b00a512e3ecb3539082093082cd952eea4/colors/base16-default-dark.vim
    colorscheme = {
      base00 = "#181818";
      base01 = "#282828";
      base02 = "#383838";
      base03 = "#585858";
      base04 = "#b8b8b8";
      base05 = "#d8d8d8";
      base06 = "#e8e8e8";
      base07 = "#f8f8f8";
      base08 = "#ab4642";
      base09 = "#dc9656";
      base0A = "#f7ca88";
      base0B = "#a1b56c";
      base0C = "#86c1b9";
      base0D = "#7cafc2";
      base0E = "#ba8baf";
      base0F = "#a16946";
    };
  };

  globals = {
    mapleader = " ";
    maplocalleader = ''\'';
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>?";
      action = lib.nixvim.mkRaw ''
        function()
          require("which-key").show({ global = false })
        end
      '';
      options.desc = "Buffer Local Keymaps (which-key)";
    }
    {
      mode = "n";
      key = "<leader>qq";
      action = "<cmd>qa<cr>";
      options.desc = "Quit All";
    }
  ];

  opts = {
    number = true;
    relativenumber = true;
  };

  # Configure NixVim without prefixing with `plugins.nixvim`
  plugins = {
    mini-icons.enable = true;
    web-devicons.enable = true;
    cmp = {
      autoEnableSources = true;
      settings.sources = [
        { name = "nvim_lsp"; }
        { name = "path"; }
        { name = "buffer"; }
      ];
    };
    which-key = {
      enable = true;
      settings = {
        expand = 1;
        preset = "helix";
        spec = lib.nixvim.mkRaw ''
          {
            {
              mode = { "n", "x" },
              { "<leader><tab>", group = "tabs" },
              { "<leader>c", group = "code" },
              { "<leader>d", group = "debug" },
              { "<leader>dp", group = "profiler" },
              { "<leader>f", group = "file/find" },
              { "<leader>g", group = "git" },
              { "<leader>gh", group = "hunks" },
              { "<leader>q", group = "quit/session" },
              { "<leader>s", group = "search" },
              { "<leader>u", group = "ui" },
              { "<leader>x", group = "diagnostics/quickfix" },
              { "[", group = "prev" },
              { "]", group = "next" },
              { "g", group = "goto" },
              { "gs", group = "surround" },
              { "z", group = "fold" },
              {
                "<leader>b",
                group = "buffer",
                expand = function()
                  return require("which-key.extras").expand.buf()
                end,
              },
              {
                "<leader>w",
                group = "windows",
                proxy = "<c-w>",
                expand = function()
                  return require("which-key.extras").expand.win()
                end,
              },
              -- better descriptions
              { "gx", desc = "Open with system app" },
            },
          },
        '';
      };
    };
  };
}

