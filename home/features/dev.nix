{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      act
      awscli2
      ssm-session-manager-plugin
      duckdb
      httpie
      jq
      lazygit
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
