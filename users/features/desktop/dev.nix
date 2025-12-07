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
