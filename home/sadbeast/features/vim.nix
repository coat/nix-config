{pkgs, ...}: {
  programs.vim = {
    enable = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      ale
      asyncomplete-vim
      asyncomplete-lsp-vim
      asyncrun-vim
      base16-vim
      copilot-vim
      lightline-vim
      lightline-ale
      lightline-lsp
      nerdtree
      nerdtree-git-plugin
      fugitive
      fzf-vim
      vim-commentary
      vim-dadbod
      vim-dispatch
      vim-dotenv
      vim-eunuch
      vim-lsp
      vim-lsp-ale
      vim-lsp-settings
      vim-mustache-handlebars
      vimspector
      vim-rails
      vim-rhubarb
      vim-signify
      vim-test
      vim-wayland-clipboard
      vim-vsnip
      vim-vsnip-integ
      zig-vim
    ];

    settings = {
      hidden = true;
      ignorecase = true;
      # mouse = "a";
      number = true;
      relativenumber = true;
      smartcase = true;
    };

    extraConfig = builtins.readFile ./vimrc;
  };
}
