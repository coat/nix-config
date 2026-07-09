{
  services.soju = {
    enable = true;
    hostName = "irc.sadbeast.com";
    tlsCertificate = "/var/lib/acme/irc.sadbeast.com/fullchain.pem";
    tlsCertificateKey = "/var/lib/acme/irc.sadbeast.com/key.pem";
  };

  systemd.services.soju = {
    # soju runs as DynamicUser; the acme module chowns the cert to acme:nginx
    # (nginx serves the vhost), so the nginx group grants read access
    serviceConfig.SupplementaryGroups = ["nginx"];
    # don't start before the cert exists on first deploy
    after = ["acme-finished-irc.sadbeast.com.target"];
    wants = ["acme-finished-irc.sadbeast.com.target"];
  };

  # SIGHUP (module's ExecReload) makes soju pick up renewed certs
  security.acme.certs."irc.sadbeast.com".reloadServices = ["soju.service"];

  # minimal vhost so nginx answers the HTTP-01 challenge for this name
  services.nginx.virtualHosts."irc.sadbeast.com" = {
    forceSSL = true;
    enableACME = true;
    locations."/".return = "301 https://sadbeast.com";
  };

  networking.firewall.allowedTCPPorts = [6697];
}
