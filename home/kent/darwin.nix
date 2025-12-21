{pkgs, ...}: {
  imports = [
    #./global
    #./features/desktop
    #./features/desktop/firefox.nix
    #./features/dev.nix
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
      warn-dirty = false;
    };
  };

  home = {
    stateVersion = "25.05";
    packages = with pkgs; [
      #aws-sam-cli
      #awscli2
      #awsvpnclient
      #devpod
      #vscode
      #vscode-extensions.github.copilot-chat
    ];

    sessionVariables = {
      CODEARTIFACT_AUTH_CMD = "aws codeartifact get-authorization-token --domain andros --domain-owner 111491220182 --region us-east-2 --query authorizationToken --output text";
    };
  };

  programs = {
    git = {
      enable = true;
      userName = "Kent Smith";
      userEmail = "kent.smith@andros.co";

      extraConfig = {
        core.sshCommand = "ssh -i ~/.ssh/id_rsa -o IdentitiesOnly=yes";
      };
    };

    ripgrep.enable = true;
    starship.enable = true;

    #ghostty = {
    #  enable = true;
    #  enableZshIntegration = true;
    #};

  };
}
