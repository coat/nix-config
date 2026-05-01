{pkgs, ...}: {
  imports = [
    ./nixvim/dev.nix
  ];
  home = {
    packages = with pkgs; [
      alejandra
      awscli2
      devenv
      duckdb
      httpie
      jq
      lazygit
      # pgcli
      # pkgs.llm-agents.amp
      pkgs.llm-agents.spec-kit
      ruby
      sox
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

    claude-code = {
      enable = true;
      package = pkgs.llm-agents.claude-code;
    };

    opencode = {
      enable = true;
      package = pkgs.llm-agents.opencode;
      settings = {
        mcp = {
          jira = {
            type = "remote";
            url = "https://mcp.atlassian.com/v1/sse";
            enabled = true;
            oauth = {};
          };
        };
      };
    };
  };
}
