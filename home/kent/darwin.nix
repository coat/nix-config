{pkgs, ...}: {
  imports = [
    ../features/global.nix
    ../features/qutebrowser.nix
    ../features/devcontainers.nix
    ../features/nvim.nix
    # ../features/ghostty.nix
  ];

  home = {
    username = "kent";

    stateVersion = "25.05";

    sessionVariables = {
      AWS_PROFILE = "andros-dev-1.SoftwareEngineer";
      CODEARTIFACT_AUTH_CMD = "aws codeartifact get-authorization-token --domain andros --domain-owner 111491220182 --region us-east-2 --query authorizationToken --output text";
    };

    packages = with pkgs; [
      awscli2
      docker-buildx
      httpie
      nodejs
      ruby-lsp
    ];
  };

  programs.git = {
    userName = "Kent Smith";
    userEmail = "kent.smith@andros.co";
  };
}
