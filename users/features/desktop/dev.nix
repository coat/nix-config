{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.charm.homeModules.crush
  ];

  home = {
    packages = with pkgs; [
      act
      amp-cli
      gcc
      nodejs
      github-copilot-cli
      imhex
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
  };
}
