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
      nodejs
      pipx
      ruby-lsp
      zig
      zls
    ];

    sessionPath = [
      "/home/sadbeast/.local/bin"
    ];
  };

  programs = {
    crush.enable = true;
    gh = {
      enable = true;
      extensions = [pkgs.gh-copilot];
      settings.aliases = {
        prs = "pr list";
      };
    };
  };
}
