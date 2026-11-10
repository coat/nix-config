# ai-beacon dashboard: monitors/orchestrates coding agents across devices.
# Runs the upstream native binary (no container) on :8090 (8080 is romm) and
# behind http://ai-beacon.local (modules/local-hostnames.nix).
#
# The browser password and the agent bearer token come from clan vars, so they
# survive reinstalls and other machines can read them:
#   clan vars get crystalpalace ai-beacon/env
# Point an agent here with:
#   AI_BEACON_AUTH_TOKEN=<token> ai-beacon install --url http://ai-beacon.local
{
  config,
  lib,
  pkgs,
  ...
}: let
  vars = config.clan.core.vars.generators.ai-beacon;
in {
  clan.core.vars.generators.ai-beacon = {
    files.env.secret = true;
    runtimeInputs = [pkgs.coreutils pkgs.openssl];
    script = ''
      {
        echo "AI_BEACON_AUTH_TOKEN=$(openssl rand -hex 32)"
        echo "AI_BEACON_AUTH_PASSWORD=$(openssl rand -hex 16)"
      } > "$out/env"
    '';
  };

  environment.systemPackages = [pkgs.ai-beacon];

  systemd.services.ai-beacon = {
    description = "ai-beacon coding agent dashboard";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      # Env vars rather than --password-file: the server chmods that file,
      # and the secret is root-owned.
      EnvironmentFile = vars.files.env.path;
      ExecStart = "${lib.getExe pkgs.ai-beacon} server --address :8090 --data-dir /var/lib/ai-beacon";
      Restart = "always";
      RestartSec = "10s";

      DynamicUser = true;
      StateDirectory = "ai-beacon";
      StateDirectoryMode = "0700";

      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
    };
  };

  networking.firewall.allowedTCPPorts = [8090];
}
