{pkgs, ...}: {
  imports = [
    ./nixvim-dev.nix
    ./devcontainers.nix
  ];
  home = {
    packages = with pkgs; [
      act
      alejandra
      amp-cli
      awscli2
      docker-buildx
      duckdb
      gcc
      github-copilot-cli
      httpie
      jq
      lazygit
      nodejs
      ruby
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
