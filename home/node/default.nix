{...}: {
  imports = [
    ../features/global.nix
  ];

  home = let
    username = "node";
  in {
    username = username;
    homeDirectory = "/home/${username}";

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
