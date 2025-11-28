{
  imports = [
    ../../modules/global.nix
    ../../users/sadbeast/nixos.nix
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443 1965];
  };

  services = {
    nginx = {
      enable = true;

      virtualHosts."sadbeast.com" = {
        forceSSL = true;
        enableACME = true;

        root = "/srv/www/sadbeast.com";
      };

      # virtualHosts."irc.sadbeast.com" = {
      #   listen = [
      #     {
      #       addr = "127.0.0.1";
      #       port = 1667;
      #       ssl = true;
      #     }
      #   ];
      #   addSSL = true;
      #   enableACME = true;
      #
      #   locations."/" = {
      #     proxyPass = "unix:/run/soju/irc.sock";
      #   };
      # };

      virtualHosts."miramiraspa.com" = {
        addSSL = true;
        enableACME = true;

        locations."/".return = "301 https://linktr.ee/Thinklikeanesthetician";
      };
    };

    # soju = {
    #   enable = true;
    # };

    stargazer = {
      enable = true;
      genCerts = true;

      routes = [
        {
          route = "sadbeast.com";
          root = "/srv/gemini/sadbeast.com";
        }
      ];
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "sadbeast@sadbeast.com";
  };
}
