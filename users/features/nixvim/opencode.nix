{lib, ...}: {
  programs.nixvim = {
    opts.autoread = true;

    plugins.opencode.enable = true;

    keymaps = [
      {
        mode = [
          "n"
          "x"
        ];
        key = "<C-a>";
        action = lib.nixvim.mkRaw ''function() require("opencode").ask("@this: ", { submit = true }) end'';
        options.desc = "Ask opencode...";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<C-x>";
        action = lib.nixvim.mkRaw ''function() require("opencode").select() end'';
        options.desc = "Execute opencode action...";
      }
      {
        mode = [
          "n"
          "t"
        ];
        key = "<C-.>";
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
        key = "<S-C-u>";
        action = lib.nixvim.mkRaw ''function() require("opencode").command("session.half.page.up") end'';
        options.desc = "Scroll opencode up";
      }
      {
        mode = "n";
        key = "<S-C-d>";
        action = lib.nixvim.mkRaw ''function() require("opencode").command("session.half.page.down") end'';
        options.desc = "Scroll opencode down";
      }
      {
        mode = "n";
        key = "+";
        action = "<C-a>";
        options = {
          desc = "Increment under cursor";
          remap = false;
        };
      }
      {
        mode = "n";
        key = "-";
        action = "<C-x>";
        options = {
          desc = "Decrement under cursor";
          remap = false;
        };
      }
    ];
  };
}
