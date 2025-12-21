{
  imports = [
    (import ../common/home-base.nix {
      username = "kent";
      realName = "Kent Smith";
      email = "kent.smith@andros.co";
      extraImports = [
        ../features/dev.nix
        ../features/desktop/dev.nix
        ../features/devcontainers.nix
      ];
    })
  ];

  nixpkgs.config.allowUnfree = true;

  home.sessionVariables = {
    AWS_PROFILE = "andros-dev-1.SoftwareEngineer";
    CODEARTIFACT_AUTH_CMD = "aws codeartifact get-authorization-token --domain andros --domain-owner 111491220182 --region us-east-2 --query authorizationToken --output text";
  };

  programs = {
    obsidian.enable = true;

    nixvim.plugins.obsidian.settings.workspaces = [
      {
        name = "work";
        path = "~/Documents/vault/work";
      }
    ];
  };
}
