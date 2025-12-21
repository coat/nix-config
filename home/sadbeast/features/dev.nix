{
  pkgs,
  config,
  ...
}: {
  home = {
    packages = with pkgs; [
      nodejs
    ];
  };

  programs = {
    gh = {
      enable = true;
      extensions = [pkgs.gh-copilot];
    };
  };
}

