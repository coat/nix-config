# AgentRun (pkgs/agentrun): control plane + one runner for unattended agent
# runs, shared by sadbeast's personal machines. pi harness only, on DeepSeek:
# the claude-agent / codex / opencode harnesses run hash-pinned prebuilt
# binaries that need nix-ld and fetch from npm on first use, so none is set up.
#
# No Docker (AGENTRUN_BOXES=none): agents get their run folder's files, web
# fetch/search and MCP tools, but no shell. Turning Docker on means giving
# this service the Docker socket, i.e. root on crystalpalace.
#
# Listens on crystalpalace's ZeroTier address only, so neither the LAN nor
# the internet reaches it; clients use http://crystalpalace:7340/v2
# (modules/zerotier-hosts.nix). Off loopback the server serves any Host and
# the token is the only lock on the API; ZeroTier carries it encrypted.
#
# Secrets (all clan vars, handed to the server over the launcher's pipe, never
# left in its environment):
#   agentrun-seal  AGENTRUN_SEAL_KEY: seals keys saved in the console. Losing
#                  it loses them; the store refuses to start with another.
#   agentrun-token the API token (modules/agentrun-token.nix)
#   agentrun-model DEEPSEEK_API_KEY, prompted
#
# First start: the console password is set by whoever opens
# http://crystalpalace:7340/ first, guarded by a setup code the server prints
# because AGENTRUN_PUBLIC_URL is set:
#   journalctl -u agentrun | grep -i 'set up'
#
# Upgrades: a new agentrun refuses an older store. Bumping pkgs/agentrun means
# moving /var/lib/private/agentrun aside and recreating agents.
{
  config,
  lib,
  pkgs,
  ...
}: let
  generators = config.clan.core.vars.generators;
  port = 7340;
  ztIp = lib.removeSuffix "\n" (builtins.readFile ../vars/shared/zerotier-ip-crystalpalace-zerotier/ip/value);
  dataDir = "/var/lib/agentrun";
in {
  imports = [./agentrun-token.nix];

  clan.core.vars.generators.agentrun-seal = {
    files.env.secret = true;
    runtimeInputs = [pkgs.coreutils pkgs.openssl];
    script = ''
      echo "AGENTRUN_SEAL_KEY=$(openssl rand -base64 32)" > "$out/env"
    '';
  };

  clan.core.vars.generators.agentrun-model = {
    files.env.secret = true;
    prompts.deepseek-api-key = {
      description = "DeepSeek API key for AgentRun's pi runs";
      type = "hidden";
    };
    runtimeInputs = [pkgs.coreutils];
    script = ''
      echo "DEEPSEEK_API_KEY=$(cat "$prompts/deepseek-api-key")" > "$out/env"
    '';
  };

  environment.systemPackages = [pkgs.agentrun];

  systemd.services.agentrun = {
    description = "AgentRun server and runner";
    after = ["network-online.target" "zerotierone.service"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    environment = {
      HOME = dataDir;
      AGENT_MODEL = "deepseek/deepseek-flash";
      AGENT_MODEL_STRONG = "deepseek/deepseek-v4-pro";
      AGENTRUN_BOXES = "none";
      AGENTRUN_PUBLIC_URL = "http://crystalpalace:${toString port}";
      NODE_ENV = "production";
    };

    serviceConfig = {
      EnvironmentFile = [
        generators.agentrun-seal.files.env.path
        generators.agentrun-token.files.env.path
        generators.agentrun-model.files.env.path
      ];
      # The launcher strips the secrets from the environment and hands them to
      # the server over a pipe (pkgs/agentrun). The ZeroTier address appears a
      # few seconds after zerotierone starts; until then the bind fails and
      # Restart retries.
      ExecStart = lib.escapeShellArgs [
        (lib.getExe' pkgs.agentrun "agentrun-serve")
        "--data"
        dataDir
        "--listen"
        ztIp
        "--port"
        (toString port)
        "--drain-timeout"
        "6s"
      ];
      Restart = "always";
      RestartSec = "10s";
      # 6 s drain plus the stop itself (upstream's image budget).
      TimeoutStopSec = "15s";

      DynamicUser = true;
      StateDirectory = "agentrun";
      StateDirectoryMode = "0700";
      WorkingDirectory = dataDir;

      MemoryMax = "2G";
      CPUQuota = "200%";

      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
    };
  };

  # Bound to the ZeroTier address above, so opening the port reaches nothing else.
  networking.firewall.allowedTCPPorts = [port];
}
