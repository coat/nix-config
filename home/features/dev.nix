{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      act
      amp-cli
      awscli2
      ssm-session-manager-plugin
      duckdb
      httpie
      nodejs
      imhex
      jq
      lazygit
      ruby
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
