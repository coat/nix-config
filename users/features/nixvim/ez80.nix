{
  pkgs,
  inputs,
  ...
}: let
  # tomm/vim-ez80 (a fork of samsaga2/vim-z80) isn't in nixpkgs. It's a pure
  # Vimscript plugin - ftdetect, ftplugin, syntax - so there's no build step.
  vim-ez80 = pkgs.vimUtils.buildVimPlugin {
    name = "vim-ez80";
    src = inputs.vim-ez80;
  };
in {
  extraPlugins = [vim-ez80];

  # The plugin never sets `commentstring`, so Neovim's native `gc`/`gcc`
  # (and ts-comments, which falls back to it) have nothing to comment with.
  # ez80 comments are `;`-prefixed.
  files."ftplugin/ez80.lua".localOpts = {
    commentstring = "; %s";
  };
}
