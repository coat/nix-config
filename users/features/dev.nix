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
      glow
      httpie
      jq
      lazygit
      # nono
      pgcli
      ruby
      sox
      spec-kit
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
    };

    opencode = {
      enable = true;
      settings = {
        lsp = true;
        plugin = ["opencode-devcontainers"];
      };
    };
  };

  xdg.configFile."opencode/devcontainers/config.json".text = ''
    {
      "portRangeStart": 13000,
      "portRangeEnd": 13099
    }
  '';
}
