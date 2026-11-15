# AgentRun CLI pointed at a remote server (modules/agentrun.nix on
# crystalpalace), plus its skill for Claude Code and OpenCode so a local agent
# can hand jobs to the server (`agentrun runs start ... --max-cost-usd N`).
#
# The token stays out of the shell environment: the `agentrun` wrapper reads
# it from `tokenFile` per call and exports AGENTRUN_API_KEY to the CLI alone.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.agentrun;

  cli = pkgs.writeShellScriptBin "agentrun" ''
    export AGENTRUN_BASE_URL=${lib.escapeShellArg cfg.url}
    if [[ -r ${lib.escapeShellArg cfg.tokenFile} ]]; then
      AGENTRUN_API_KEY=$(<${lib.escapeShellArg cfg.tokenFile})
      export AGENTRUN_API_KEY
    else
      echo "agentrun: no token at ${cfg.tokenFile} (clan vars not deployed?)" >&2
    fi
    exec ${lib.getExe pkgs.agentrun} "$@"
  '';

  skill = "${pkgs.agentrun}/lib/agentrun/packages/agentrun/skills/agentrun-cli";
in {
  options.agentrun = {
    url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "http://crystalpalace:7340/v2";
      description = "AgentRun API base URL (ending in /v2); null leaves the CLI uninstalled.";
    };

    tokenFile = lib.mkOption {
      type = lib.types.str;
      description = "Runtime path of a file holding the bare API token.";
    };
  };

  config = lib.mkIf (cfg.url != null) {
    home.packages = [cli];

    programs.claude-code.skills.agentrun-cli = skill;
    programs.opencode.skills.agentrun-cli = skill;
  };
}
