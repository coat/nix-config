{inputs, pkgs, ...}: {
  home = {
    packages = with pkgs; [
      act
      amp-cli
      awscli2
      duckdb
      github-copilot-cli
      httpie
      imhex
      jq
      lazygit
      nodejs
      ruby
      ssm-session-manager-plugin
    ];
  };

  programs = {
    crush = {
      enable = true;
      settings = {
        # tui = { compact_mode = true; };
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
