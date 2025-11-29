{
  pkgs,
  inputs,
  ...
}: {
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "amp-nvim";
      src = inputs.amp-nvim;
    })
  ];

  extraConfigLua = ''
    require("amp").setup({})
  '';
}
