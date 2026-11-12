# Atuin: shell history plus Threads, the captured Claude Code / OpenCode
# sessions you can search and resume (or fork into the other agent) with
# `atuin resume`, and an MCP server agents use to search both.
#
# `atuin.syncAddress = null` keeps everything on this machine: no sync, and
# sync_address points at a dead local port so even a stray `atuin login`
# can't reach Atuin's cloud. Set it to the self-hosted server
# (modules/atuin-server.nix) to sync instead; the account is a one-time manual
# step (`atuin register` on the first machine, `atuin login` with that
# machine's `atuin key` on the rest).
#
# The MCP server is declared below (programs.mcp); don't run `atuin mcp
# install`: for Claude it adds a duplicate to ~/.claude.json, and OpenCode's
# config is HM-managed. Threads are already on, whatever its hint says.
#
# Thread capture runs in the daemon, which reads the agents' own transcripts.
# The hooks below are separate: they tag the shell commands agents run in
# history (`atuin search --author '$all-agent'`).
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.atuin;
  atuin = config.programs.atuin.package;

  # `atuin hook install opencode` picks the plugin's shape from
  # `opencode --version`, so generate it against the opencode we ship. It
  # spawns `atuin` from PATH, so the file holds no store path.
  opencodePlugin =
    pkgs.runCommand "atuin-opencode-plugin" {
      nativeBuildInputs = [atuin config.programs.opencode.package];
    } ''
      export HOME=$TMPDIR XDG_CONFIG_HOME=$TMPDIR/config XDG_DATA_HOME=$TMPDIR/data
      atuin hook install opencode >/dev/null
      cp $XDG_CONFIG_HOME/opencode/plugins/atuin.ts $out
    '';
in {
  options.atuin = {
    enable = lib.mkEnableOption "Atuin shell history and coding-agent thread capture";

    syncAddress = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "http://crystalpalace:8888";
      description = "Self-hosted Atuin sync server; null keeps history and threads local-only.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      daemon.enable = true;
      # Atuin takes ctrl-r (fzf's binding is switched off below); fzf keeps
      # ctrl-t/alt-c, and ctrl-r for users without Atuin. The up arrow stays
      # plain zsh. `?` would send the prompt to Atuin's hosted AI; keep it off.
      # ctrl-] opens the `atuin resume` thread picker, seeded with the line.
      flags = ["--disable-up-arrow" "--disable-ai" "--bind-ai-resume"];
      settings = {
        # Substring matching, like the fzf history widget's --exact
        # (features/global.nix).
        search_mode = "fulltext";
        update_check = false;
        ai.enabled = false;
        threads.capture = true;
        auto_sync = cfg.syncAddress != null;
        sync_address =
          if cfg.syncAddress != null
          then cfg.syncAddress
          else "http://127.0.0.1:9";
      };
    };

    # Empty FZF_CTRL_R_COMMAND: fzf skips its ctrl-r binding, leaving it to
    # Atuin (HM warns while both claim it).
    programs.fzf.historyWidget.command = "";

    programs.mcp = {
      enable = true;
      servers.atuin = {
        command = lib.getExe atuin;
        args = ["mcp"];
      };
    };
    programs.claude-code.enableMcpIntegration = true;
    programs.opencode.enableMcpIntegration = true;

    xdg.configFile."opencode/plugins/atuin.ts" = lib.mkIf config.programs.opencode.enable {
      source = opencodePlugin;
    };

    # Claude Code hooks live in the mutable ~/.claude/settings.json and carry
    # atuin's store path, so re-run on every activation (idempotent; replaces
    # stale paths). After ai-beacon, which re-serializes that file; the two
    # keep each other's entries either way.
    home.activation.atuinClaudeHooks = lib.mkIf config.programs.claude-code.enable (
      lib.hm.dag.entryAfter ["writeBoundary" "aiBeaconHooks"] ''
        run ${lib.getExe atuin} hook install claude-code >/dev/null
      ''
    );
  };
}
