{
  pkgs,
  ...
}: {
  home = {
    packages = with pkgs; [
      devcontainer
      devpod
      httpie
      jq
      imhex
      lazygit
      mise
      nodejs
      zig
      zls
    ];
  };

  programs = {
    gh = {
      enable = true;
      extensions = [pkgs.gh-copilot];
    };
  };
}
