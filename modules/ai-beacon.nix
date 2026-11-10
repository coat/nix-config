# ai-beacon dashboard: monitors/orchestrates coding agents across devices.
# Runs the upstream native binary (no container) on :8090 (8080 is romm) and
# behind http://ai-beacon.local (modules/local-hostnames.nix).
#
# The browser password is a clan var, so it survives reinstalls:
#   clan vars get crystalpalace ai-beacon-password/env
# The agent bearer token is the shared `ai-beacon-token` var
# (modules/ai-beacon-token.nix); users/sadbeast/nixos.nix points every
# personal machine's agents here with it.
{
  config,
  lib,
  pkgs,
  ...
}: let
  generators = config.clan.core.vars.generators;
in {
  imports = [./ai-beacon-token.nix];

  clan.core.vars.generators.ai-beacon-password = {
    files.env.secret = true;
    runtimeInputs = [pkgs.coreutils pkgs.openssl];
    script = ''
      echo "AI_BEACON_AUTH_PASSWORD=$(openssl rand -hex 16)" > "$out/env"
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
      EnvironmentFile = [
        generators.ai-beacon-password.files.env.path
        generators.ai-beacon-token.files.env.path
      ];
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
