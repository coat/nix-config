{lib, ...}: {
  imports = [
    ./nixvim/autocmds.nix
    ./nixvim/cmp.nix
    ./nixvim/flash.nix
    ./nixvim/gitsigns.nix
    ./nixvim/grug-far.nix
    ./nixvim/keymaps.nix
    ./nixvim/lsp.nix
    ./nixvim/lualine.nix
    ./nixvim/noice.nix
    ./nixvim/snacks.nix
    ./nixvim/todo-comments.nix
    ./nixvim/trouble.nix
    ./nixvim/which-key.nix
  ];

  enable = true;
  # You can use lib.nixvim in your config
  # fooOption = lib.nixvim.mkRaw "print('hello')";

  colorschemes.base16 = {
    enable = true;
    # https://github.com/tinted-theming/tinted-vim/blob/483154b00a512e3ecb3539082093082cd952eea4/colors/base16-default-dark.vim
    colorscheme = {
      base00 = "#181818";
      base01 = "#282828";
      base02 = "#383838";
      base03 = "#585858";
      base04 = "#b8b8b8";
      base05 = "#d8d8d8";
      base06 = "#e8e8e8";
      base07 = "#f8f8f8";
      base08 = "#ab4642";
      base09 = "#dc9656";
      base0A = "#f7ca88";
      base0B = "#a1b56c";
      base0C = "#86c1b9";
      base0D = "#7cafc2";
      base0E = "#ba8baf";
      base0F = "#a16946";
    };
  };

  globals = {
    mapleader = " ";
    maplocalleader = ''\'';
    autoformat = true;
    snacks_animate = false;
    ai_cmp = true;
    deprecation_warnings = false;
    trouble_lualine = true;
    markdown_recommended_style = 0;
  };

  opts = {
    autowrite = true;
    clipboard = lib.nixvim.mkRaw ''vim.env.SSH_CONNECTION and "" or "unnamedplus"'';
    completeopt = "menu,menuone,noselect";
    conceallevel = 2;
    confirm = true;
    cursorline = true;
    expandtab = true;
    fillchars = {
      foldopen = "";
      foldclose = "";
      fold = " ";
      foldsep = " ";
      diff = "╱";
      eob = " ";
    };
    foldlevel = 99;
    foldmethod = "indent";
    foldtext = "";
    formatoptions = "jcroqlnt";
    grepformat = "%f:%l:%c:%m";
    grepprg = "rg --vimgrep";
    ignorecase = true;
    inccommand = "nosplit";
    jumpoptions = "view";
    laststatus = 3;
    linebreak = true;
    list = true;
    mouse = "a";
    number = true;
    pumblend = 10;
    pumheight = 10;
    relativenumber = true;
    ruler = false;
    scrolloff = 4;
    sessionoptions = "buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds";
    shiftround = true;
    shiftwidth = 2;
    shortmess = "WclC"; # Note: NixVim might expect string or list for shortmess flags
    showmode = false;
    sidescrolloff = 8;
    signcolumn = "yes";
    smartcase = true;
    smartindent = true;
    smoothscroll = true;
    spelllang = ["en"];
    splitbelow = true;
    splitkeep = "screen";
    splitright = true;
    tabstop = 2;
    termguicolors = true;
    timeoutlen = 300;
    undofile = true;
    undolevels = 10000;
    updatetime = 200;
    virtualedit = "block";
    wildmode = "longest:full,full";
    winminwidth = 5;
    wrap = false;
  };

  # Configure NixVim without prefixing with `plugins.nixvim`
  plugins = {
    mini-icons.enable = true;
    nui.enable = true;
    web-devicons.enable = true;
  };
}
