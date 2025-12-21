{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      act
      awscli2
      ssm-session-manager-plugin
      devcontainer
      devpod
      duckdb
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
