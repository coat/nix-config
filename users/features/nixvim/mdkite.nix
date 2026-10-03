{
  pkgs,
  inputs,
  ...
}: let
  # selimacerbas/mdkite.nvim (formerly markdown-preview.nvim) isn't in nixpkgs,
  # and nixvim's built-in `plugins.markdown-preview` wraps iamcco's node-based
  # plugin instead. Both of these are pure Lua, so there's no build step.
  kitehost-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "kitehost-nvim";
    src = inputs.kitehost-nvim;
  };

  mdkite-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "mdkite-nvim";
    src = inputs.mdkite-nvim;
    # mdkite requires kitehost modules at load time, so kitehost has to be on
    # the runtimepath — including during the neovimRequireCheck hook, which
    # only sees `dependencies`.
    dependencies = [kitehost-nvim];
    # The deprecated `markdown_preview` shim warns when required.
    nvimSkipModules = ["markdown_preview"];
  };
in {
  extraPlugins = [
    kitehost-nvim
    mdkite-nvim
  ];

  extraConfigLua = ''
    require("mdkite").setup({
      instance_mode = "takeover",
      port = 0,
      open_browser = true,
      default_theme = "dark",
      debounce_ms = 300,
    })
  '';

  keymaps = [
    {
      mode = "n";
      key = "<leader>mp";
      action = "<cmd>MdKite start<cr>";
      options.desc = "Start markdown preview";
    }
    {
      mode = "n";
      key = "<leader>mr";
      action = "<cmd>MdKite refresh<cr>";
      options.desc = "Refresh markdown preview";
    }
    {
      mode = "n";
      key = "<leader>ms";
      action = "<cmd>MdKite stop<cr>";
      options.desc = "Stop markdown preview";
    }
  ];
}
