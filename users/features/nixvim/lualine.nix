{lib, ...}: {
  plugins.lualine = {
    enable = true;
    settings = {
      options = {
        theme = "auto";
        globalstatus = true;
        disabled_filetypes = {
          statusline = ["dashboard" "alpha" "ministarter" "snacks_dashboard"];
        };
      };
      sections = {
        lualine_a = ["mode"];
        lualine_b = ["branch"];
        lualine_c = [
          (lib.nixvim.mkRaw ''
            function()
              return Snacks.git.get_root() ~= nil and vim.fn.fnamemodify(Snacks.git.get_root(), ":t") or vim.fn.expand("%:p:h:t")
            end
          '')
          {
            __unkeyed-1 = "diagnostics";
            symbols = {
              error = " ";
              warn = " ";
              info = " ";
              hint = " ";
            };
          }
          {
            __unkeyed-1 = "filetype";
            icon_only = true;
            separator = "";
            padding = {
              left = 1;
              right = 0;
            };
          }
          {
            __unkeyed-1 = "filename";
            path = 1; # Relative path
            symbols = {
              modified = "  ";
              readonly = "";
              unnamed = "";
            };
          }
        ];
        lualine_x = [
          (lib.nixvim.mkRaw ''
            {
              function() return require("noice").api.status.command.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              color = { fg = "#ff9e64" },
            }
          '')
          (lib.nixvim.mkRaw ''
            {
              function() return require("noice").api.status.mode.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
              color = { fg = "#ff9e64" },
            }
          '')
          (lib.nixvim.mkRaw ''
            {
              function() return "  " .. require("dap").status() end,
              cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
              color = { fg = "#ff9e64" },
            }
          '')
          {
            __unkeyed-1 = "diff";
            symbols = {
              added = " ";
              modified = " ";
              removed = " ";
            };
            source = lib.nixvim.mkRaw ''
              function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end
            '';
          }
        ];
        lualine_y = [
          {
            __unkeyed-1 = "progress";
            separator = " ";
            padding = {
              left = 1;
              right = 0;
            };
          }
          {
            __unkeyed-1 = "location";
            padding = {
              left = 0;
              right = 1;
            };
          }
        ];
        lualine_z = [
          (lib.nixvim.mkRaw ''
            function()
              return " " .. os.date("%R")
            end
          '')
        ];
      };
      extensions = ["neo-tree"];
    };
  };
}
