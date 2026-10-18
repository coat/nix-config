# Public front door for the RomM instance that lives on crystalpalace.
# cheyenne terminates TLS for romm.sadbeast.com and forwards the request home
# over ZeroTier; the 3.3 TB ROM library never has to leave the house.
{
  services.nginx.virtualHosts."romm.sadbeast.com" = {
    forceSSL = true;
    enableACME = true;

    locations."/" = {
      # `crystalpalace` resolves to its ZeroTier IP via modules/zerotier-hosts.nix.
      # Hits crystalpalace's own nginx, which owns the romm.sadbeast.com vhost
      # on that side (see modules/romm.nix).
      proxyPass = "http://crystalpalace:80";
      proxyWebsockets = true;
      recommendedProxySettings = true;
      extraConfig = ''
        # ROM transfers are large and slow: don't spool them onto the VPS disk
        # and don't cut them off mid-flight.
        client_max_body_size 0;
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_read_timeout 3600;
        proxy_send_timeout 3600;
      '';
    };
  };
}
