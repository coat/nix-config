# ai-beacon agent hooks (pkgs/ai-beacon). Setting `ai-beacon.url` reports
# Claude Code and OpenCode sessions to that dashboard.
#
# `ai-beacon install` writes the binary's resolved /nix/store path into every
# Claude hook, the status line and its config.toml, so a package bump plus a
# GC leaves the hooks pointing at nothing. It is idempotent and rewrites its own
# (`# ai-beacon-managed`) entries in place, so re-run it on every activation.
#
# The token is not managed here: install points token_path at
# <data-dir>/token, which a server on the same machine writes itself. For a
# remote dashboard, run once by hand with AI_BEACON_AUTH_TOKEN set.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ai-beacon;
in {
  options.ai-beacon.url = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "http://localhost:8090";
    description = "Dashboard URL to register agent hooks with; null leaves hooks alone.";
  };

  config = lib.mkIf (cfg.url != null) {
    home.packages = [pkgs.ai-beacon];

    # Note: install re-serializes settings.json hooks and drops fields it does
    # not model (e.g. the herdr SessionStart hook's `timeout`).
    home.activation.aiBeaconHooks = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${lib.getExe pkgs.ai-beacon} install --url ${lib.escapeShellArg cfg.url} --yes >/dev/null
    '';

    # Start agents through the wrapper so their terminal can be attached from
    # the dashboard (hooks alone are monitor-only). Functions, not aliases:
    # the wrapper always runs the agent on its own PTY, which mangles piped
    # output and never sees EOF on stdin (`echo … | claude -p` hangs), so only
    # wrap when stdin and stdout are terminals. AI_BEACON_WRAPPER is set inside
    # a wrapped session; don't nest.
    #
    # herdr finds agents by the pane's foreground process, which is now
    # ai-beacon (the agent runs on the wrapper's PTY), so the pane drops out of
    # herdr's agent panel. HERDR_AGENT on that process is herdr's override.
    programs.zsh.initContent = ''
      claude() {
        if [[ -t 0 && -t 1 && -z $AI_BEACON_WRAPPER ]]; then
          HERDR_AGENT=claude ai-beacon session -- claude "$@"
        else
          command claude "$@"
        fi
      }
      opencode() {
        if [[ -t 0 && -t 1 && -z $AI_BEACON_WRAPPER ]]; then
          HERDR_AGENT=opencode ai-beacon session -- opencode "$@"
        else
          command opencode "$@"
        fi
      }
    '';
  };
}
