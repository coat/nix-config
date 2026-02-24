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
      ruby
      ssm-session-manager-plugin
      tree-sitter
    ];
  };

  programs = {
    gh = {
      enable = true;
      settings.aliases = {
        prs = "pr list";
      };
    };
  };
}
