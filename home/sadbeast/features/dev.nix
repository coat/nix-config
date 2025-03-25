{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      awscli2
      devcontainer
      devpod
      httpie
      jq
      imhex
      lazygit
      mise
      nodejs
      pipx
      zig
      zls
    ];

    sessionPath = [
      "/home/sadbeast/.local/bin"
    ];
  };

  programs = {
    gh = {
      enable = true;
      extensions = [pkgs.gh-copilot];
    };
  };
}
