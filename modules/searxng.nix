# SearXNG metasearch, LAN-only at http://searx.local/
# The mDNS alias for searx.local is published by ./local-hostnames.nix; the
# nginx vhost comes from the searx module itself (configureNginx), which wires
# up the uwsgi socket and static assets for us.
{
  config,
  pkgs,
  ...
}: let
  vars = config.clan.core.vars.generators.searxng;
in {
  clan.core.vars.generators.searxng = {
    files.searxng-env.secret = true;
    runtimeInputs = [pkgs.coreutils pkgs.openssl];
    script = ''
      echo "SEARXNG_SECRET=$(openssl rand -hex 32)" > "$out/searxng-env"
    '';
  };

  services.searx = {
    enable = true;
    domain = "searx.local";
    configureNginx = true; # implies configureUwsgi

    # configureNginx points the vassal at /run/searx/uwsgi.sock, but the module
    # merges uwsgiConfig last and its default (http = ":8080") is applied on top.
    # 8080 is romm here, so the bind fails and uwsgi curses the whole vassal.
    # Empty it so the socket is the only listener.
    uwsgiConfig = {};

    # Keeps the key out of the world-readable store: searx-init runs envsubst
    # over settings.yml with this file loaded as its EnvironmentFile.
    environmentFile = vars.files.searxng-env.path;

    settings = {
      server = {
        secret_key = "$SEARXNG_SECRET";
        # Bot/rate limiting needs redis and only matters for public instances.
        limiter = false;
        image_proxy = true;
      };
      search = {
        safe_search = 0;
        autocomplete = "duckduckgo";
        # html for the UI, json so other tools on the LAN can query it
        formats = ["html" "json"];
      };
      ui.query_in_title = true;
    };
  };
}
