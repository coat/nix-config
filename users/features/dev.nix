{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.charm.homeModules.crush
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
      imhex
      jq
      lazygit
      nodejs
      ruby
      ssm-session-manager-plugin
      tree-sitter
    ];
  };

  programs = {
    crush = {
      enable = true;
      settings = {
        options = {
          tui = {compact_mode = true;};
        };
        mcp = {
          playwright = {
            type = "http";
            url = "http://localhost:8931/mcp";
            disabled = false;
          };
        };
      };
    };

    gh = {
      enable = true;
      extensions = [pkgs.gh-copilot];
      settings.aliases = {
        prs = "pr list";
      };
    };
  };
}
