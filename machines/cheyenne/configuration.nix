{
  imports = [
    ../../modules/global.nix
    ../../modules/docker.nix
    ../../modules/docker-registry.nix
    ../../modules/soju.nix
    ../../users/teamdraft/nixos.nix
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

      virtualHosts."teamdraft.party" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
      };

      virtualHosts."registry.teamdraft.party" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:5000";
          recommendedProxySettings = true;
          extraConfig = ''
            client_max_body_size 0;
            proxy_read_timeout 900;
            proxy_buffering off;
            proxy_request_buffering off;
          '';
        };
      };

      virtualHosts."miramiraspa.com" = {
        addSSL = true;
        enableACME = true;

        locations."/".return = "301 https://linktr.ee/Thinklikeanesthetician";
      };

      virtualHosts."gnarlyboutique.com" = {
        serverAliases = ["www.gnarlyboutique.com" "gnarlyboutique.com"];

        addSSL = true;
        enableACME = true;

        locations."/".return = "301 https://gnarly.boutique";
      };
    };

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
