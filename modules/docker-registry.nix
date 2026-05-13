{
  config,
  pkgs,
  ...
}: let
  vars = config.clan.core.vars.generators.teamdraft-registry;
in {
  clan.core.vars.generators.teamdraft-registry = {
    share = false;
    files.htpasswd = {
      secret = true;
      owner = "docker-registry";
      mode = "0400";
    };
    prompts.username = {
      description = "Teamdraft container registry username";
    };
    prompts.password = {
      description = "Teamdraft container registry password";
      type = "hidden";
    };
    script = ''
      ${pkgs.apacheHttpd}/bin/htpasswd -nbB \
        "$(cat "$prompts/username")" \
        "$(cat "$prompts/password")" \
        > "$out/htpasswd"
    '';
  };

  services.dockerRegistry = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 5000;
    extraConfig = {
      auth = {
        htpasswd = {
          realm = "teamdraft-registry";
          path = vars.files.htpasswd.path;
        };
      };
    };
  };
}
