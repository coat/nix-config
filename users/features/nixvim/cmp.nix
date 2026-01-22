{lib, ...}: {
  plugins.blink-copilot.enable = true;
  plugins.blink-cmp = {
    enable = true;
    settings = {
      snippets = {
        preset = "default";
      };

      appearance = {
        use_nvim_cmp_as_default = false;
        nerd_font_variant = "mono";
      };

      completion = {
        accept = {
          auto_brackets = {
            enabled = true;
          };
        };
        menu = {
          draw = {
            treesitter = ["lsp"];
          };
        };
        documentation = {
          auto_show = true;
          auto_show_delay_ms = 200;
        };
        ghost_text = {
          enabled = false;
        };
      };

      sources = {
        default = ["lsp" "path" "snippets" "buffer" "copilot"];
        cmdline = [];
        providers = {
          copilot = {
            async = true;
            module = "blink-copilot";
            name = "copilot";
            score_offset = 100;
            # Optional configurations
            opts = {
              max_completions = 3;
              max_attempts = 4;
              kind = "Copilot";
              debounce = 750;
              auto_refresh = {
                backward = true;
                forward = true;
              };
            };
          };
        };
      };

      cmdline = {
        enabled = true;
        keymap = {
          preset = "cmdline";
          "<Right>" = [];
          "<Left>" = [];
        };
        completion = {
          list = {selection = {preselect = false;};};
          menu = {
            auto_show = lib.nixvim.mkRaw ''
              function(ctx)
                return vim.fn.getcmdtype() == ":"
              end
            '';
          };
          ghost_text = {enabled = true;};
        };
      };

      keymap = {
        preset = "enter";
        "<C-y>" = ["select_and_accept"];
      };
    };
  };

  plugins.mini-pairs = {
    enable = true;
    settings = {
      modes = {
        command = true;
        insert = true;
        terminal = false;
      };

      skip_next = lib.nixvim.mkRaw ''[=[[%w%%%'%[%"%.%`%$]]=]'';
      skip_ts = ["string"];

      skip_unbalanced = true;

      markdown = true;
    };
  };
}
