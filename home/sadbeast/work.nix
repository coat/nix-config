{pkgs, ...}: {
  imports = [
    ./global
    ./features/desktop
    ./features/desktop/firefox.nix
    ./features/dev.nix
    ./features/desktop
  ];

  home = {
    packages = with pkgs; [
      # adrs
      aws-sam-cli
      awscli2
      awsvpnclient
      devpod
      vscode
      vscode-extensions.github.copilot-chat
      gcc
      glow
      libreoffice
      #localstack
      nodejs
      ngrok
      pipx
      pop
      pgcli
      #ruby
      #ruby-lsp
      sshfs
      #slack
      ssm-session-manager-plugin
      tmate
      virt-manager
      zoom
    ];

    sessionVariables = {
      CODEARTIFACT_AUTH_CMD = "aws codeartifact get-authorization-token --domain andros --domain-owner 111491220182 --region us-east-2 --query authorizationToken --output text";
    };

    sessionPath = [
      "/home/sadbeast/.local/bin"
    ];
  };

  programs = {
    git = {
      userName = "Kent Smith";
      userEmail = "kent.smith@andros.co";

      extraConfig = {
        core.sshCommand = "ssh -i ~/.ssh/id_rsa -o IdentitiesOnly=yes";
      };
    };

    # obs-studio = {
    #   enable = true;
    #   plugins = with pkgs.obs-studio-plugins; [
    #     wlrobs
    #     obs-backgroundremoval
    #     obs-pipewire-audio-capture
    #   ];
    # };

    qutebrowser = {
      settings.content.blocking.whitelist = [
        "app.bugsnag.com"
      ];
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };

  wayland.windowManager.sway.config.output = {
    eDP-1 = {disable = "disable";};
    # eDP-1 = {
    #   disable = true;
    #   # resolution = "1920x1080";
    #   # position = "0,0";
    # };
    HDMI-A-1 = {
      resolution = "1920x1080";
      # position = "0,1080";
      position = "0,0";
    };
    DP-1 = {
      resolution = "1920x1080";
      # position = "1920,1080";
      position = "1920,0";
    };
  };
}
