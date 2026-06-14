{
  lib,
  pkgs,
  ...
}: {
  opts.autoread = true;

  plugins.opencode.enable = true;

  keymaps = [
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>aa";
      action = lib.nixvim.mkRaw ''function() require("opencode").ask("@this: ", { submit = true }) end'';
      options.desc = "Ask opencode...";
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>as";
      action = lib.nixvim.mkRaw ''function() require("opencode").select() end'';
      options.desc = "Execute opencode action...";
    }
    {
      mode = "n";
      key = "<leader>at";
      action = lib.nixvim.mkRaw ''function() require("opencode").toggle() end'';
      options.desc = "Toggle opencode";
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "go";
      action = lib.nixvim.mkRaw ''function() return require("opencode").operator("@this ") end'';
      options = {
        desc = "Add range to opencode";
        expr = true;
      };
    }
    {
      mode = "n";
      key = "goo";
      action = lib.nixvim.mkRaw ''function() return require("opencode").operator("@this ") .. "_" end'';
      options = {
        desc = "Add line to opencode";
        expr = true;
      };
    }
    {
      mode = "n";
      key = "<a-C-u>";
      action = lib.nixvim.mkRaw ''function() require("opencode").command("session.half.page.up") end'';
      options.desc = "Scroll opencode up";
    }
    {
      mode = "n";
      key = "<a-C-d>";
      action = lib.nixvim.mkRaw ''function() require("opencode").command("session.half.page.down") end'';
      options.desc = "Scroll opencode down";
    }
  ];

  extraConfigLua = ''
    vim.g.opencode_opts = {
      server = {
        start = function()
          require("snacks.terminal").open("opencode --port 0", {
            win = {
              position = "right",
              enter = false,
              on_win = function(win)
                require("opencode.terminal").setup(win.win)
              end,
            },
          })
        end,
        stop = function()
          local cmd = "opencode --port 0"
          local opts = {
            win = { position = "right" },
          }
          require("snacks.terminal").get(cmd, opts):close()
        end,
        toggle = function()
          local cmd = "opencode --port 0"
          local opts = {
            win = {
              position = "right",
              enter = false,
              on_win = function(win)
                require("opencode.terminal").setup(win.win)
              end,
            },
          }
          require("snacks.terminal").toggle(cmd, opts)
        end,
      },
    }
  '';
}
