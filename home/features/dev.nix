{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      awscli2
      devcontainer
      devpod
      httpie
      jq
      lazygit
      nodejs
      ruby
      ruby-lsp
    ];
  };

  programs = {
    gh = {
      enable = true;
      extensions = [pkgs.gh-copilot];
      settings.aliases = {
        prs = "pr list";
      };
    };
  };
}
