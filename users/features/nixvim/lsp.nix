{lib, ...}: {
  plugins.lsp = {
    enable = true;
    inlayHints = true;

    servers = {
      lua_ls = {
        enable = true;
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false;
            };
            codeLens = {
              enable = true;
            };
            completion = {
              callSnippet = "Replace";
            };
            doc = {
              privateName = ["^_"];
            };
            hint = {
              enable = true;
              setType = false;
              paramType = true;
              paramName = "Disable";
              semicolon = "Disable";
              arrayIndex = "Disable";
            };
          };
        };
      };
      zls = {
        enable = true;
      };
    };

    keymaps = {
      silent = true;
      lspBuf = {
        "K" = {
          action = "hover";
          desc = "Hover";
        };
        "gK" = {
          action = "signature_help";
          desc = "Signature Help";
        };
        "<c-k>" = {
          action = "signature_help";
          desc = "Signature Help";
        };
        "<leader>ca" = {
          action = "code_action";
          desc = "Code Action";
        };
        "<leader>cr" = {
          action = "rename";
          desc = "Rename";
        };
      };
      extra = [
        {
          key = "gd";
          action = lib.nixvim.mkRaw ''function() Snacks.picker.lsp_definitions() end'';
          options.desc = "Goto Definition";
        }
        {
          key = "gr";
          action = lib.nixvim.mkRaw ''function() Snacks.picker.lsp_references() end'';
          options = {
            desc = "References";
            nowait = true;
          };
        }
        {
          key = "gD";
          action = lib.nixvim.mkRaw ''function() Snacks.picker.lsp_declarations() end'';
          options.desc = "Goto Declaration";
        }
        {
          key = "gI";
          action = lib.nixvim.mkRaw ''function() Snacks.picker.lsp_implementations() end'';
          options.desc = "Goto Implementation";
        }
        {
          key = "gy";
          action = lib.nixvim.mkRaw ''function() Snacks.picker.lsp_type_definitions() end'';
          options.desc = "Goto T[y]pe Definition";
        }
        {
          key = "<leader>cl";
          action = lib.nixvim.mkRaw ''function() Snacks.picker.lsp_config() end'';
          options.desc = "Lsp Info";
        }
        {
          key = "<leader>cc";
          action = lib.nixvim.mkRaw ''vim.lsp.codelens.run'';
          options.desc = "Run Codelens";
        }
        {
          key = "<leader>cC";
          action = lib.nixvim.mkRaw ''vim.lsp.codelens.refresh'';
          options.desc = "Refresh & Display Codelens";
        }
        {
          key = "<leader>cR";
          action = lib.nixvim.mkRaw ''function() Snacks.rename.rename_file() end'';
          options.desc = "Rename File";
        }
        {
          key = "]]";
          action = lib.nixvim.mkRaw ''function() Snacks.words.jump(vim.v.count1) end'';
          options.desc = "Next Reference";
        }
        {
          key = "[[";
          action = lib.nixvim.mkRaw ''function() Snacks.words.jump(-vim.v.count1) end'';
          options.desc = "Prev Reference";
        }
        {
          key = "<a-n>";
          action = lib.nixvim.mkRaw ''function() Snacks.words.jump(vim.v.count1, true) end'';
          options.desc = "Next Reference";
        }
        {
          key = "<a-p>";
          action = lib.nixvim.mkRaw ''function() Snacks.words.jump(-vim.v.count1, true) end'';
          options.desc = "Prev Reference";
        }
      ];
    };
  };

  # Diagnostics configuration
  extraConfigLua = ''
    vim.diagnostic.config({
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
      },
      severity_sort = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = " ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      },
    })
  '';
}