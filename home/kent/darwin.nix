{...}: {
  imports = [
    ../features/global.nix
    ../features/qutebrowser.nix
    ../features/devcontainers.nix
    # ../features/ghostty.nix
  ];

  home = {
    username = "kent";

    stateVersion = "25.05";

    sessionVariables = {
      CODEARTIFACT_AUTH_CMD = "aws codeartifact get-authorization-token --domain andros --domain-owner 111491220182 --region us-east-2 --query authorizationToken --output text";
    };
  };

  programs.git = {
    userName = "Kent Smith";
    userEmail = "kent.smith@andros.co";
  };
}
