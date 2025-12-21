{lib, ...}: {
  plugins.which-key = {
    enable = true;
    settings = {
      expand = 1;
      preset = "helix";
      spec = [
        {
          __unkeyed-1 = "<leader><tab>";
          group = "tabs";
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "<leader>c";
          group = "code";
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "<leader>d";
          group = "debug";
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "<leader>dp";
          group = "profiler";
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "<leader>f";
          group = "file/find";
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "<leader>g";
          group = "git";
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "<leader>gh";
          group = "hunks";
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "<leader>q";
          group = "quit/session";
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "<leader>s";
          group = "search";
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "<leader>u";
          group = "ui";
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "<leader>x";
          group = "diagnostics/quickfix";
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "[";
          group = "prev";
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "]";
          group = "next";
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "g";
          group = "goto";
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "gs";
          group = "surround";
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "z";
          group = "fold";
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "<leader>b";
          group = "buffer";
          expand = lib.nixvim.mkRaw ''
            function()
              return require("which-key.extras").expand.buf()
            end
          '';
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "<leader>w";
          group = "windows";
          proxy = "<c-w>";
          expand = lib.nixvim.mkRaw ''
            function()
              return require("which-key.extras").expand.win()
            end
          '';
          mode = ["n" "x"];
        }
        {
          __unkeyed-1 = "gx";
          desc = "Open with system app";
          mode = ["n" "x"];
        }
      ];
    };
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
  ];
}
