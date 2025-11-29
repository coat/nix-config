{lib, ...}: {
  globals.snacks_animate = false;

  plugins.snacks = {
    enable = true;
    settings = {
      indent = {
        enabled = true;
      };
      input = {
        enabled = true;
      };
      notifier = {
        enabled = true;
        level = lib.nixvim.mkRaw ''vim.log.levels.WARN'';
      };
      scope = {
        enabled = true;
      };
      scroll = {
        enabled = true;
      };
      statuscolumn = {
        enabled = false;
      };
      words = {
        enabled = true;
      };
      bigfile = {
        enabled = true;
      };
      quickfile = {
        enabled = true;
      };
      terminal = {
        win = {
          keys = {
            nav_h = {
              __unkeyed-1 = "<C-h>";
              __unkeyed-2 = "<C-\\><C-N><C-w>h";
              desc = "Go to Left Window";
              mode = "t";
            };
            nav_j = {
              __unkeyed-1 = "<C-j>";
              __unkeyed-2 = "<C-\\><C-N><C-w>j";
              desc = "Go to Lower Window";
              mode = "t";
            };
            nav_k = {
              __unkeyed-1 = "<C-k>";
              __unkeyed-2 = "<C-\\><C-N><C-w>k";
              desc = "Go to Upper Window";
              mode = "t";
            };
            nav_l = {
              __unkeyed-1 = "<C-l>";
              __unkeyed-2 = "<C-\\><C-N><C-w>l";
              desc = "Go to Right Window";
              mode = "t";
            };
          };
        };
      };
      picker = {
        enabled = true;
      };
      explorer = {
        enabled = true;
      };
      dashboard = {
        enabled = true;
        sections = [
          {section = "header";}
          {
            section = "keys";
            gap = 1;
            padding = 1;
          }
          {
            section = "startup";
            enabled = false;
          }
        ];
        preset = {
          keys = [
            {
              icon = " ";
              key = "f";
              desc = "Find File";
              action = ":lua Snacks.dashboard.pick('files')";
            }
            {
              icon = " ";
              key = "n";
              desc = "New File";
              action = ":ene | startinsert";
            }
            {
              icon = " ";
              key = "g";
              desc = "Find Text";
              action = ":lua Snacks.dashboard.pick('live_grep')";
            }
            {
              icon = " ";
              key = "r";
              desc = "Recent Files";
              action = ":lua Snacks.dashboard.pick('oldfiles')";
            }
            {
              icon = " ";
              key = "c";
              desc = "Config";
              action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.expand('~/projects/nix-config')})";
            }
            {
              icon = " ";
              key = "s";
              desc = "Restore Session";
              section = "session";
            }
            {
              icon = " ";
              key = "q";
              desc = "Quit";
              action = ":qa";
            }
          ];
        };
      };
    };
  };

  keymaps = [
    # Top Pickers & Explorer
    {
      mode = "n";
      key = "<leader><space>";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.smart() end'';
      options.desc = "Smart Find Files";
    }
    {
      mode = "n";
      key = "<leader>,";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.buffers() end'';
      options.desc = "Buffers";
    }
    {
      mode = "n";
      key = "<leader>/";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.grep() end'';
      options.desc = "Grep";
    }
    {
      mode = "n";
      key = "<leader>:";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.command_history() end'';
      options.desc = "Command History";
    }
    {
      mode = "n";
      key = "<leader>n";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.notifications() end'';
      options.desc = "Notification History";
    }
    {
      mode = "n";
      key = "<leader>e";
      action = lib.nixvim.mkRaw ''function() Snacks.explorer() end'';
      options.desc = "File Explorer";
    }

    # Find
    {
      mode = "n";
      key = "<leader>fb";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.buffers() end'';
      options.desc = "Buffers";
    }
    {
      mode = "n";
      key = "<leader>fc";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end'';
      options.desc = "Find Config File";
    }
    {
      mode = "n";
      key = "<leader>ff";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.files() end'';
      options.desc = "Find Files";
    }
    {
      mode = "n";
      key = "<leader>fg";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.git_files() end'';
      options.desc = "Find Git Files";
    }
    {
      mode = "n";
      key = "<leader>fp";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.projects() end'';
      options.desc = "Projects";
    }
    {
      mode = "n";
      key = "<leader>fr";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.recent() end'';
      options.desc = "Recent";
    }

    # Git
    {
      mode = "n";
      key = "<leader>gb";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.git_branches() end'';
      options.desc = "Git Branches";
    }
    {
      mode = "n";
      key = "<leader>gl";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.git_log() end'';
      options.desc = "Git Log";
    }
    {
      mode = "n";
      key = "<leader>gL";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.git_log_line() end'';
      options.desc = "Git Log Line";
    }
    {
      mode = "n";
      key = "<leader>gs";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.git_status() end'';
      options.desc = "Git Status";
    }
    {
      mode = "n";
      key = "<leader>gS";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.git_stash() end'';
      options.desc = "Git Stash";
    }
    {
      mode = "n";
      key = "<leader>gd";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.git_diff() end'';
      options.desc = "Git Diff (Hunks)";
    }
    {
      mode = "n";
      key = "<leader>gf";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.git_log_file() end'';
      options.desc = "Git Log File";
    }

    # GitHub
    {
      mode = "n";
      key = "<leader>gi";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.gh_issue() end'';
      options.desc = "GitHub Issues (open)";
    }
    {
      mode = "n";
      key = "<leader>gI";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.gh_issue({ state = "all" }) end'';
      options.desc = "GitHub Issues (all)";
    }
    {
      mode = "n";
      key = "<leader>gp";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.gh_pr() end'';
      options.desc = "GitHub Pull Requests (open)";
    }
    {
      mode = "n";
      key = "<leader>gP";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.gh_pr({ state = "all" }) end'';
      options.desc = "GitHub Pull Requests (all)";
    }

    # Grep
    {
      mode = "n";
      key = "<leader>sb";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.lines() end'';
      options.desc = "Buffer Lines";
    }
    {
      mode = "n";
      key = "<leader>sB";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.grep_buffers() end'';
      options.desc = "Grep Open Buffers";
    }
    {
      mode = "n";
      key = "<leader>sg";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.grep() end'';
      options.desc = "Grep";
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>sw";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.grep_word() end'';
      options.desc = "Visual selection or word";
    }

    # Search
    {
      mode = "n";
      key = "<leader>s\"";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.registers() end'';
      options.desc = "Registers";
    }
    {
      mode = "n";
      key = "<leader>s/";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.search_history() end'';
      options.desc = "Search History";
    }
    {
      mode = "n";
      key = "<leader>sa";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.autocmds() end'';
      options.desc = "Autocmds";
    }
    {
      mode = "n";
      key = "<leader>sc";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.command_history() end'';
      options.desc = "Command History";
    }
    {
      mode = "n";
      key = "<leader>sC";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.commands() end'';
      options.desc = "Commands";
    }
    {
      mode = "n";
      key = "<leader>sd";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.diagnostics() end'';
      options.desc = "Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>sD";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.diagnostics_buffer() end'';
      options.desc = "Buffer Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>sh";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.help() end'';
      options.desc = "Help Pages";
    }
    {
      mode = "n";
      key = "<leader>sH";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.highlights() end'';
      options.desc = "Highlights";
    }
    {
      mode = "n";
      key = "<leader>si";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.icons() end'';
      options.desc = "Icons";
    }
    {
      mode = "n";
      key = "<leader>sj";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.jumps() end'';
      options.desc = "Jumps";
    }
    {
      mode = "n";
      key = "<leader>sk";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.keymaps() end'';
      options.desc = "Keymaps";
    }
    {
      mode = "n";
      key = "<leader>sl";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.loclist() end'';
      options.desc = "Location List";
    }
    {
      mode = "n";
      key = "<leader>sm";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.marks() end'';
      options.desc = "Marks";
    }
    {
      mode = "n";
      key = "<leader>sM";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.man() end'';
      options.desc = "Man Pages";
    }
    {
      mode = "n";
      key = "<leader>sp";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.lazy() end'';
      options.desc = "Search for Plugin Spec";
    }
    {
      mode = "n";
      key = "<leader>sq";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.qflist() end'';
      options.desc = "Quickfix List";
    }
    {
      mode = "n";
      key = "<leader>sR";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.resume() end'';
      options.desc = "Resume";
    }
    {
      mode = "n";
      key = "<leader>su";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.undo() end'';
      options.desc = "Undo History";
    }
    {
      mode = "n";
      key = "<leader>uC";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.colorschemes() end'';
      options.desc = "Colorschemes";
    }

    # LSP
    {
      mode = "n";
      key = "gd";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.lsp_definitions() end'';
      options.desc = "Goto Definition";
    }
    {
      mode = "n";
      key = "gD";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.lsp_declarations() end'';
      options.desc = "Goto Declaration";
    }
    {
      mode = "n";
      key = "gr";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.lsp_references() end'';
      options = {
        desc = "References";
        nowait = true;
      };
    }
    {
      mode = "n";
      key = "gI";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.lsp_implementations() end'';
      options.desc = "Goto Implementation";
    }
    {
      mode = "n";
      key = "gy";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.lsp_type_definitions() end'';
      options.desc = "Goto T[y]pe Definition";
    }
    {
      mode = "n";
      key = "gai";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.lsp_incoming_calls() end'';
      options.desc = "C[a]lls Incoming";
    }
    {
      mode = "n";
      key = "gao";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.lsp_outgoing_calls() end'';
      options.desc = "C[a]lls Outgoing";
    }
    {
      mode = "n";
      key = "<leader>ss";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.lsp_symbols() end'';
      options.desc = "LSP Symbols";
    }
    {
      mode = "n";
      key = "<leader>sS";
      action = lib.nixvim.mkRaw ''function() Snacks.picker.lsp_workspace_symbols() end'';
      options.desc = "LSP Workspace Symbols";
    }

    {
      mode = "n";
      key = "<leader>un";
      action = lib.nixvim.mkRaw ''function() Snacks.notifier.hide() end'';
      options.desc = "Dismiss All Notifications";
    }
    {
      mode = "n";
      key = "<leader>.";
      action = lib.nixvim.mkRaw ''function() Snacks.scratch() end'';
      options.desc = "Toggle Scratch Buffer";
    }
    {
      mode = "n";
      key = "<leader>S";
      action = lib.nixvim.mkRaw ''function() Snacks.scratch.select() end'';
      options.desc = "Select Scratch Buffer";
    }
    {
      mode = "n";
      key = "<leader>dps";
      action = lib.nixvim.mkRaw ''function() Snacks.profiler.scratch() end'';
      options.desc = "Profiler Scratch Buffer";
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>gB";
      action = lib.nixvim.mkRaw ''function() Snacks.gitbrowse() end'';
      options.desc = "Git Browse (open)";
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>gY";
      action = lib.nixvim.mkRaw ''
        function()
          Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
        end
      '';
      options.desc = "Git Browse (copy)";
    }
  ];

  extraConfigLua = ''
    Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
    Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
    Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
    Snacks.toggle.diagnostics():map("<leader>ud")
    Snacks.toggle.line_number():map("<leader>ul")
    Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }):map("<leader>uc")
    Snacks.toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }):map("<leader>uA")
    Snacks.toggle.treesitter():map("<leader>uT")
    Snacks.toggle.option("background", { off = "light", on = "dark" , name = "Dark Background" }):map("<leader>ub")
    Snacks.toggle.dim():map("<leader>uD")
    Snacks.toggle.animate():map("<leader>ua")
    Snacks.toggle.indent():map("<leader>ug")
    Snacks.toggle.scroll():map("<leader>uS")
    Snacks.toggle.profiler():map("<leader>dpp")
    Snacks.toggle.profiler_highlights():map("<leader>dph")

    if vim.lsp.inlay_hint then
      Snacks.toggle.inlay_hints():map("<leader>uh")
    end

    Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
    Snacks.toggle.zen():map("<leader>uz")

    Snacks.toggle({
      name = "Git Signs",
      get = function()
        return require("gitsigns.config").config.signcolumn
      end,
      set = function(state)
        require("gitsigns").toggle_signs(state)
      end,
    }):map("<leader>uG")
  '';
}
