{
  pkgs,
  inputs,
  ...
}: let
  # selimacerbas/markdown-preview.nvim isn't in nixpkgs, and nixvim's built-in
  # `plugins.markdown-preview` wraps iamcco's node-based plugin instead. Both of
  # these are pure Lua, so there's no build step.
  live-server-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "live-server-nvim";
    src = inputs.live-server-nvim;
  };

  markdown-preview-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "markdown-preview-nvim";
    src = inputs.markdown-preview-nvim;
    # markdown_preview does `require("live_server.server")` at load time, so
    # live-server has to be on the runtimepath — including during the
    # neovimRequireCheck hook, which only sees `dependencies`.
    dependencies = [live-server-nvim];
  };
in {
  extraPlugins = [
    live-server-nvim
    markdown-preview-nvim
  ];

  extraConfigLua = ''
    require("markdown_preview").setup({
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
      action = "<cmd>MarkdownPreview<cr>";
      options.desc = "Start markdown preview";
    }
    {
      mode = "n";
      key = "<leader>mr";
      action = "<cmd>MarkdownPreviewRefresh<cr>";
      options.desc = "Refresh markdown preview";
    }
    {
      mode = "n";
      key = "<leader>ms";
      action = "<cmd>MarkdownPreviewStop<cr>";
      options.desc = "Stop markdown preview";
    }
  ];
}
