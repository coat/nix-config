{
  pkgs,
  lib,
  ...
}: let
  ruby-lsp-wrapper = pkgs.writeShellScriptBin "ruby-lsp-wrapper" ''
    # The gem-installed binstub calls Gem.use_gemdeps, which resolves gems
    # from the nearest Gemfile.  Point it at the composed .ruby-lsp/Gemfile
    # (which eval_gemfile's the project Gemfile + adds LSP gems) so it can
    # resolve ruby-lsp + project deps correctly.
    if [ -f "$PWD/.ruby-lsp/Gemfile" ]; then
      export BUNDLE_GEMFILE="$PWD/.ruby-lsp/Gemfile"

      # If the project uses a devenv ruby bundle, make sure its gems are
      # discoverable — even before direnv has loaded in neovim.
      # Use only bash builtins; the LSP process may have a minimal PATH.
      if [ -d "$PWD/.devenv/state/.bundle/ruby" ]; then
        for rd in "$PWD/.devenv/state/.bundle/ruby"/*; do
          if [ -d "$rd" ]; then
            export GEM_HOME="$rd"
            export GEM_PATH="$GEM_HOME/gems''${GEM_PATH:+:$GEM_PATH}"
            export PATH="$GEM_HOME/bin''${PATH:+:$PATH}"
            break
          fi
        done
      fi
    fi
    exec ruby-lsp "$@"
  '';
in {
  plugins.lsp = {
    enable = true;
    inlayHints = false;

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
      gopls.enable = true;
      nil_ls.enable = true;
      postgres_lsp.enable = true;

      ruby_lsp = {
        enable = true;
        package = null;
        cmd = [(lib.getExe ruby-lsp-wrapper)];
        settings = {
          rubyLsp = {
            featuresConfiguration = {
              codeLens = true;
            };
          };
        };
      };
      terraformls.enable = true;
      ts_ls.enable = true;
      zls.enable = true;
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
          action = lib.nixvim.mkRaw ''
            function()
              if vim.g.codelens_enabled then
                vim.lsp.codelens.clear()
                vim.g.codelens_enabled = false
              else
                vim.lsp.codelens.refresh()
                vim.g.codelens_enabled = true
              end
            end
          '';
          options.desc = "Toggle codelens";
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
    -- ruby-lsp custom command handlers
    vim.lsp.commands["rubyLsp.openFile"] = function(cmd, _)
      local uri_frag = cmd.arguments[1][1]
      local uri, line = uri_frag:match("^(.+)%%23L(%d+)$")
      if not uri then
        uri, line = uri_frag:match("^(.+)#L(%d+)$")
      end
      if not uri then
        uri = uri_frag
      end
      local bufnr = vim.uri_to_bufnr(uri)
      vim.fn.bufload(bufnr)
      vim.api.nvim_set_option_value("buflisted", true, { buf = bufnr })
      vim.api.nvim_set_current_buf(bufnr)
      vim.api.nvim_win_set_cursor(0, { tonumber(line) or 1, 0 })
    end

    do
      local function has_file(dir, name)
        return vim.fn.filereadable(dir .. "/" .. name) == 1
      end

      local function find_ruby_project_root(bufnr)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        if fname == "" then
          return nil
        end
        local dir = vim.fn.fnamemodify(fname, ":p:h")
        local prev = ""
        while dir ~= prev do
          if has_file(dir, ".standard.yml") or has_file(dir, ".rubocop.yml") then
            return dir
          end
          prev = dir
          dir = vim.fn.fnamemodify(dir, ":h")
        end
        return nil
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "ruby",
        callback = function(args)
          local bufnr = args.buf
          local root = find_ruby_project_root(bufnr)
          if not root then
            return
          end

          local lsp_clients = vim.lsp.get_clients({bufnr = bufnr})
          for _, c in ipairs(lsp_clients) do
            if c.name == "rubocop" or c.name == "standardrb" then
              return
            end
          end

          -- RuboCop is handled by ruby-lsp's built-in RuboCop addon (run from the
          -- project bundle), so we no longer start a standalone rubocop client.
          -- Keep standardrb as a fallback for projects using Standard.
          if has_file(root, ".standard.yml") then
            vim.lsp.start({
              name = "standardrb",
              cmd = {"standardrb", "--lsp"},
              root_dir = root,
            }, {bufnr = bufnr})
          end
        end,
      })
    end

    -- ruby-lsp resolves its gems from the project environment (GEM_HOME, PATH)
    -- that direnv injects. If the client started before direnv finished loading
    -- (or nvim was launched outside the project), (re)start it once the env is ready.
    vim.api.nvim_create_autocmd("User", {
      pattern = "DirenvLoaded",
      callback = function()
        vim.schedule(function()
          local bufnr = vim.api.nvim_get_current_buf()
          if vim.bo[bufnr].filetype ~= "ruby" then
            return
          end
          if vim.tbl_isempty(vim.lsp.get_clients({ name = "ruby_lsp", bufnr = bufnr })) then
            pcall(vim.cmd, "LspStart ruby_lsp")
          else
            pcall(vim.cmd, "LspRestart ruby_lsp")
          end
        end)
      end,
    })

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
