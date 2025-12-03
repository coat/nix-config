{outputs, ...}: {
  imports =
    [
      ../features/global.nix
      ../features/dev.nix
      ../features/devcontainers.nix
    ];
    # ++ (builtins.attrValues outputs.homeManagerModules);

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "kent";

    stateVersion = "25.05";

    sessionVariables = {
      AWS_PROFILE = "andros-dev-1.SoftwareEngineer";
      CODEARTIFACT_AUTH_CMD = "aws codeartifact get-authorization-token --domain andros --domain-owner 111491220182 --region us-east-2 --query authorizationToken --output text";
    };
  };

  programs.git = {
    userName = "Kent Smith";
    userEmail = "kent.smith@andros.co";
  };
}
