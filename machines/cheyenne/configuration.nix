{
  imports = [
    ../../modules/global.nix
    ../../users/sadbeast/nixos.nix
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 1965 ];
  };

  services.nginx = {
    enable = true;

    virtualHosts."sadbeast.com" = {
      addSSL = true;
      enableACME = true;

      root = "/var/www/sadbeast.com";
    };

    virtualHosts."miramiraspa.com" = {
      addSSL = true;
      enableACME = true;

      locations."/".return = "301 https://linktr.ee/Thinklikeanesthetician";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "sadbeast@sadbeast.com";
  };
}
