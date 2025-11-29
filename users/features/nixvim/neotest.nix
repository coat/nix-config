{lib, ...}: {
  plugins.neotest = {
    enable = true;
    settings = {
      status = {
        virtual_text = true;
      };
      output = {
        open_on_run = true;
      };
      quickfix = {
        open = lib.nixvim.mkRaw ''
          function()
            if require("trouble") then
              require("trouble").open({ mode = "quickfix", focus = false })
            else
              vim.cmd("copen")
            end
          end
        '';
      };
    };
    adapters = {
      zig = {
        enable = true;
        settings = {
          dap = {
            adapter = "lldb";
          };
        };
      };
      rspec.enable = true;
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>t";
      action = "";
      options.desc = "+test";
    }
    {
      mode = "n";
      key = "<leader>ta";
      action = lib.nixvim.mkRaw ''function() require("neotest").run.attach() end'';
      options.desc = "Attach to Test (Neotest)";
    }
    {
      mode = "n";
      key = "<leader>tt";
      action = lib.nixvim.mkRaw ''function() require("neotest").run.run(vim.fn.expand("%")) end'';
      options.desc = "Run File (Neotest)";
    }
    {
      mode = "n";
      key = "<leader>tT";
      action = lib.nixvim.mkRaw ''function() require("neotest").run.run(vim.uv.cwd()) end'';
      options.desc = "Run All Test Files (Neotest)";
    }
    {
      mode = "n";
      key = "<leader>tr";
      action = lib.nixvim.mkRaw ''function() require("neotest").run.run() end'';
      options.desc = "Run Nearest (Neotest)";
    }
    {
      mode = "n";
      key = "<leader>tl";
      action = lib.nixvim.mkRaw ''function() require("neotest").run.run_last() end'';
      options.desc = "Run Last (Neotest)";
    }
    {
      mode = "n";
      key = "<leader>ts";
      action = lib.nixvim.mkRaw ''function() require("neotest").summary.toggle() end'';
      options.desc = "Toggle Summary (Neotest)";
    }
    {
      mode = "n";
      key = "<leader>to";
      action = lib.nixvim.mkRaw ''function() require("neotest").output.open({ enter = true, auto_close = true }) end'';
      options.desc = "Show Output (Neotest)";
    }
    {
      mode = "n";
      key = "<leader>tO";
      action = lib.nixvim.mkRaw ''function() require("neotest").output_panel.toggle() end'';
      options.desc = "Toggle Output Panel (Neotest)";
    }
    {
      mode = "n";
      key = "<leader>tS";
      action = lib.nixvim.mkRaw ''function() require("neotest").run.stop() end'';
      options.desc = "Stop (Neotest)";
    }
    {
      mode = "n";
      key = "<leader>tw";
      action = lib.nixvim.mkRaw ''function() require("neotest").watch.toggle(vim.fn.expand("%")) end'';
      options.desc = "Toggle Watch (Neotest)";
    }
  ];
}
