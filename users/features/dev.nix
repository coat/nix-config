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
      pkgs.llm-agents.amp
      pkgs.llm-agents.copilot-cli
      pkgs.llm-agents.opencode
      pkgs.llm-agents.spec-kit
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
