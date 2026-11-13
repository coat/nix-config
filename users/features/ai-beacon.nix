# ai-beacon agent hooks (pkgs/ai-beacon). Setting `ai-beacon.url` reports
# Claude Code and OpenCode sessions to that dashboard.
#
# `ai-beacon install` writes the binary's resolved /nix/store path into every
# Claude hook, the status line and its config.toml, so a package bump plus a
# GC leaves the hooks pointing at nothing. It is idempotent and rewrites its own
# (`# ai-beacon-managed`) entries in place, so re-run it on every activation.
#
# Token: install points token_path at <data-dir>/token. A server run by the
# same user writes that file itself (the work laptop); for a remote dashboard
# set `ai-beacon.tokenEnvFile`, and install copies the token from it.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ai-beacon;
  tokenEnvFile = lib.escapeShellArg cfg.tokenEnvFile;
in {
  options.ai-beacon = {
    url = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "http://localhost:8090";
      description = "Dashboard URL to register agent hooks with; null leaves hooks alone.";
    };

    tokenEnvFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Runtime path of a file holding `AI_BEACON_AUTH_TOKEN=<token>` for the
        dashboard at `url`; null when the dashboard runs as this user.
      '';
    };

    projectsDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/projects";
      defaultText = lib.literalExpression ''"''${config.home.homeDirectory}/projects"'';
      description = "Root the dashboard's New session dialog lists repos from.";
    };
  };

  config = lib.mkIf (cfg.url != null) {
    home.packages = [pkgs.ai-beacon];

    # Note: install re-serializes settings.json hooks and drops fields it does
    # not model (e.g. the herdr SessionStart hook's `timeout`).
    #
    # Subshell so the token does not leak into later activation steps. A
    # missing file (secret not deployed yet) must not fail the activation.
    home.activation.aiBeaconHooks = lib.hm.dag.entryAfter ["writeBoundary"] ''
      (
        ${lib.optionalString (cfg.tokenEnvFile != null) ''
        if [[ -r ${tokenEnvFile} ]]; then
          set -a
          . ${tokenEnvFile}
          set +a
        else
          warnEcho "ai-beacon: cannot read ${tokenEnvFile}; hooks installed without a token"
        fi
      ''}
        run ${lib.getExe pkgs.ai-beacon} install --url ${lib.escapeShellArg cfg.url} --yes >/dev/null
      )

      # opencode 2.x rejects a plugin whose default export has no setup/effect
      # ("Plugin must export a default definition with an id and an effect or
      # setup function"); upstream's bridge (v4) exports only { id, server }.
      # Add a no-op setup, as herdr's own opencode plugin does. Exact-line
      # match, so this goes inert once upstream changes the export.
      plugin=${lib.escapeShellArg "${config.xdg.configHome}/opencode/plugins/ai-beacon.ts"}
      if [[ -f $plugin ]] && grep -qx 'export default { id: "ai-beacon", server }' "$plugin"; then
        run sed -i 's/^export default { id: "ai-beacon", server }$/export default { id: "ai-beacon", server, setup() {} }/' "$plugin"
      fi
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
    #
    # AI_BEACON_PROJECTS_DIR: roots the dashboard's New session dialog lists
    # repos from (unset, the device is read-only there). Set here rather than
    # in config.toml, which install neither writes nor keeps, and rather than
    # home.sessionVariables, whose __HM_SESS_VARS_SOURCED guard is inherited
    # from the long-running herdr server and skips new vars in its panes.
    programs.zsh.initContent = ''
      export AI_BEACON_PROJECTS_DIR=${lib.escapeShellArg cfg.projectsDir}

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
