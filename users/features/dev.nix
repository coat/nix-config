{pkgs, ...}: {
  imports = [
    ./nixvim/dev.nix
  ];
  home = {
    packages = with pkgs; [
      alejandra
      awscli2
      duckdb
      httpie
      jq
      lazygit
      pgcli
      ssm-session-manager-plugin
      tree-sitter
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
