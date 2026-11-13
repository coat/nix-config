# ai-beacon dashboard for microvms/pairvm.nix, separate from crystalpalace's
# (modules/ai-beacon.nix) so guests never see sessions on my own machines.
# Public at https://pair.sadbeast.com: cheyenne (modules/pair-relay.nix) ->
# joshua:8091 (modules/microvm.nix dashboardProxyPort) -> here :8090.
#
# Runs as the pair user, like the work Mac's instance: the server generates its
# own password and agent token in ~/.config/ai-beacon/, and the HM hooks
# (users/features/ai-beacon.nix) pick the token up from there. /home is a
# persistent volume, so both survive VM restarts. Anyone who can SSH in already
# controls everything here, so they may read the password:
#   ssh -p 2222 pair@pair.sadbeast.com cat .config/ai-beacon/password
{
  config,
  lib,
  pkgs,
  ...
}: let
  user = "pair";
  home = config.users.users.${user}.home;
  # The joshua end of the guest bridge; socket-proxyd there opens the
  # connection, so it's the only peer allowed to relay cheyenne's
  # X-Forwarded-* (real client IP for the login rate limiter).
  bridgeAddress = "192.168.83.1";
in {
  systemd.services.ai-beacon = {
    description = "ai-beacon coding agent dashboard";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    unitConfig.RequiresMountsFor = home;

    serviceConfig = {
      User = user;
      ExecStart = lib.escapeShellArgs [
        (lib.getExe pkgs.ai-beacon)
        "server"
        "--address=:8090"
        "--allowed-origins=https://pair.sadbeast.com"
        "--trusted-proxies=${bridgeAddress}/32"
      ];
      Restart = "always";
      RestartSec = "10s";
    };
  };

  networking.firewall.allowedTCPPorts = [8090];

  home-manager.users.${user}.ai-beacon = {
    url = "http://localhost:8090";
    projectsDir = "${home}/workspace";
  };
}
