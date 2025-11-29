{lib, ...}: {
  plugins.dap = {
    enable = true;
    signs = {
      dapBreakpoint = {
        text = "●";
        texthl = "DapBreakpoint";
      };
      dapBreakpointCondition = {
        text = "⊜";
        texthl = "DapBreakpointCondition";
      };
      dapLogPoint = {
        text = "◆";
        texthl = "DapLogPoint";
      };
    };
  };

  plugins.dap-ui = {
    enable = true;
  };

  plugins.dap-virtual-text = {
    enable = true;
  };

  plugins.dap-lldb = {
    enable = true;
  };

  extraConfigLua = ''
    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

    local dap, dapui = require("dap"), require("dapui")
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open({})
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close({})
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close({})
    end
  '';

  keymaps = [
    {
      mode = "n";
      key = "<leader>dB";
      action = lib.nixvim.mkRaw ''function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end'';
      options.desc = "Breakpoint Condition";
    }
    {
      mode = "n";
      key = "<leader>db";
      action = lib.nixvim.mkRaw ''function() require("dap").toggle_breakpoint() end'';
      options.desc = "Toggle Breakpoint";
    }
    {
      mode = "n";
      key = "<leader>dc";
      action = lib.nixvim.mkRaw ''function() require("dap").continue() end'';
      options.desc = "Run/Continue";
    }
    {
      mode = "n";
      key = "<leader>da";
      action = lib.nixvim.mkRaw ''
        function()
          require("dap").continue({ before = function(config)
            local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
            local new_args = vim.fn.input("Run with args: ", table.concat(args, " "))
            return vim.split(new_args, " ")
          end })
        end
      '';
      options.desc = "Run with Args";
    }
    {
      mode = "n";
      key = "<leader>dC";
      action = lib.nixvim.mkRaw ''function() require("dap").run_to_cursor() end'';
      options.desc = "Run to Cursor";
    }
    {
      mode = "n";
      key = "<leader>dg";
      action = lib.nixvim.mkRaw ''function() require("dap").goto_() end'';
      options.desc = "Go to Line (No Execute)";
    }
    {
      mode = "n";
      key = "<leader>di";
      action = lib.nixvim.mkRaw ''function() require("dap").step_into() end'';
      options.desc = "Step Into";
    }
    {
      mode = "n";
      key = "<leader>dj";
      action = lib.nixvim.mkRaw ''function() require("dap").down() end'';
      options.desc = "Down";
    }
    {
      mode = "n";
      key = "<leader>dk";
      action = lib.nixvim.mkRaw ''function() require("dap").up() end'';
      options.desc = "Up";
    }
    {
      mode = "n";
      key = "<leader>dl";
      action = lib.nixvim.mkRaw ''function() require("dap").run_last() end'';
      options.desc = "Run Last";
    }
    {
      mode = "n";
      key = "<leader>do";
      action = lib.nixvim.mkRaw ''function() require("dap").step_out() end'';
      options.desc = "Step Out";
    }
    {
      mode = "n";
      key = "<leader>dO";
      action = lib.nixvim.mkRaw ''function() require("dap").step_over() end'';
      options.desc = "Step Over";
    }
    {
      mode = "n";
      key = "<leader>dP";
      action = lib.nixvim.mkRaw ''function() require("dap").pause() end'';
      options.desc = "Pause";
    }
    {
      mode = "n";
      key = "<leader>dr";
      action = lib.nixvim.mkRaw ''function() require("dap").repl.toggle() end'';
      options.desc = "Toggle REPL";
    }
    {
      mode = "n";
      key = "<leader>ds";
      action = lib.nixvim.mkRaw ''function() require("dap").session() end'';
      options.desc = "Session";
    }
    {
      mode = "n";
      key = "<leader>dt";
      action = lib.nixvim.mkRaw ''function() require("dap").terminate() end'';
      options.desc = "Terminate";
    }
    {
      mode = "n";
      key = "<leader>dw";
      action = lib.nixvim.mkRaw ''function() require("dap.ui.widgets").hover() end'';
      options.desc = "Widgets";
    }
    {
      mode = "n";
      key = "<leader>du";
      action = lib.nixvim.mkRaw ''function() require("dapui").toggle({ }) end'';
      options.desc = "Dap UI";
    }
    {
      mode = ["n" "x"];
      key = "<leader>de";
      action = lib.nixvim.mkRaw ''function() require("dapui").eval() end'';
      options.desc = "Eval";
    }
  ];
}
