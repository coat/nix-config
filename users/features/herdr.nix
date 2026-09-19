{
  pkgs,
  lib,
  config,
  nixosConfig ? null,
  ...
}: let
  # Plugins built by nix (see pkgs/herdr-*). Each package's $out is the
  # plugin_root: herdr-plugin.toml plus whatever the manifest's commands
  # reference, and passthru.herdrPlugin carries the manifest id/name.
  plugins = with pkgs; [
    herdr-auto-title
    herdr-worktreeinclude-local
    herdr-radar
  ];

  # Herdr's plugin registry (~/.config/herdr/plugins.json). Only the fields
  # without a serde default are needed; herdr re-reads the rest from
  # manifest_path on every load. `[[build]]` steps only run during
  # `herdr plugin install`, so a pre-built store path is never rebuilt.
  registry =
    map (p: {
      plugin_id = p.passthru.herdrPlugin.id;
      inherit (p.passthru.herdrPlugin) name;
      inherit (p) version;
      manifest_path = "${p}/herdr-plugin.toml";
      plugin_root = "${p}";
      enabled = true;
    })
    plugins;

  # Same layout herdr uses for per-plugin dirs (src/plugin_paths.rs).
  pluginStateDir = id: "${config.xdg.stateHome}/herdr/plugins/${id}";

  radar = pkgs.herdr-radar;
  radarId = radar.passthru.herdrPlugin.id;

  # herdr-radar's own settings. `variant = "font"` and follow_appearance off
  # pin the two inputs that would otherwise make its daemon rewrite
  # config.toml at runtime (font detection, desktop light/dark polling).
  radarConfigText = ''
    variant = "font"
    follow_appearance = false
  '';
  radarConfig = pkgs.writeTextDir "config.toml" radarConfigText;

  # Dark theme closest to the stylix scheme (base16 eighties). Anything but
  # "terminal" also lets herdr-radar pick its light/dark palette from the
  # name; with follow_appearance off that is its only input.
  baseConfig = pkgs.writeText "herdr-config-base.toml" ''
    onboarding = false

    [keys]
    prefix = "ctrl+a"

    [theme]
    name = "one-dark"

    # herdr-radar appends its managed blocks below (needs [ui] to exist).
    [ui]
  '';

  # herdr-radar wants to write three marker-fenced blocks into config.toml
  # ([ui] tab_bar_right, [theme.custom], [ui.sidebar.*]) via `configure.js
  # --apply`, normally at install. Run that at build time against the base
  # config instead. The tab-bar block bakes in the plugin's state dir, which
  # must be writable while the script runs, so it targets a sandbox path
  # that is rewritten to the real one afterwards.
  herdrConfig =
    pkgs.runCommand "herdr-config.toml" {
      nativeBuildInputs = [pkgs.nodejs];
    } ''
      export HOME=$TMPDIR/home XDG_CONFIG_HOME=$TMPDIR/config
      export HERDR_PLUGIN_CONFIG_DIR=${radarConfig}
      export HERDR_RADAR_STATE=$TMPDIR/state
      mkdir -p "$HOME" "$XDG_CONFIG_HOME/herdr" "$HERDR_RADAR_STATE"
      install -m644 ${baseConfig} "$XDG_CONFIG_HOME/herdr/config.toml"
      node ${radar}/bin/configure.js --apply
      sed "s|$HERDR_RADAR_STATE|${pluginStateDir radarId}|g" \
        "$XDG_CONFIG_HOME/herdr/config.toml" > "$out"
    '';

  userFontDir =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Library/Fonts"
    else ".local/share/fonts";

  # Agent integrations (`herdr integration install <agent>`): herdr drops a
  # hook script into the agent's config dir and registers it. The assets ship
  # in herdr's source, so linking them from pkgs.herdr.src keeps `herdr
  # integration status` reporting "current" across herdr bumps.
  integrationAssets = "${pkgs.herdr.src}/src/integration/assets";

  # The claude hook shells out to python3 for the socket call and silently
  # exits when it is not on PATH, which on NixOS it usually is not.
  claudeHook = pkgs.runCommand "herdr-agent-state.sh" {} ''
    substitute ${integrationAssets}/claude/herdr-agent-state.sh "$out" \
      --replace-fail 'command -v python3 >/dev/null 2>&1 || exit 0' ': # python3 pinned below' \
      --replace-fail "python3 - <<'PY'" "${lib.getExe pkgs.python3} - <<'PY'"
    chmod +x "$out"
  '';

  claudeDir = config.programs.claude-code.configDir;
  claudeHookPath = "${claudeDir}/hooks/herdr-agent-state.sh";
  claudeHookCommand = "bash '${claudeHookPath}' session";
  claudeHookEntry = builtins.toJSON {
    # Claude's documented SessionStart sources (integration/claude_settings.rs).
    matcher = "^(startup|resume|clear|compact|fork)$";
    hooks = [
      {
        type = "command";
        command = claudeHookCommand;
        timeout = 10;
      }
    ];
  };
  # Saved SSH machines (what `herdr machine add` writes). Profile ids must be
  # 32 lowercase hex chars; deriving them from the label keeps them stable
  # across hosts. The entry naming the current host is dropped.
  thisHost = nixosConfig.networking.hostName or null;
  machineCatalog = {
    version = 1;
    ssh =
      map (name: {
        id = builtins.hashString "md5" name;
        label = name;
        target = name;
        session = "default";
        enabled = true;
      })
      (builtins.filter (name: name != thisHost) config.herdr.machines);
  };
in {
  options.herdr.machines = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "SSH config host aliases to list as herdr machines.";
  };

  config = lib.mkMerge [
    {
      # Managed read-only like plugins.json: `herdr machine add/remove` will
      # fail; edit herdr.machines instead. force restores the link if a CLI
      # write renamed over it.
      xdg.stateFile."herdr/client/endpoints.json" = lib.mkIf (config.herdr.machines != []) {
        source = (pkgs.formats.json {}).generate "herdr-endpoints.json" machineCatalog;
        force = true;
      };

      home = {
        # Managed read-only: `herdr plugin install/enable/disable` will fail to
        # write the registry. Add plugins to the list above instead.
        file.".config/herdr/plugins.json".source =
          (pkgs.formats.json {}).generate "herdr-plugins.json" registry;

        # herdr-radar's actions (configure, view-native, settings) rename over
        # this file, which would replace the symlink; force puts it back on the
        # next activation.
        file.".config/herdr/config.toml" = {
          source = herdrConfig;
          force = true;
        };

        file.".config/herdr/plugins/config/${radarId}/config.toml".text = radarConfigText;

        # lib/font.js checks for <name>-<hash>.ttf in the user font dir; linking
        # each file from the package keeps the hashed name without knowing it at
        # eval time, and makes radar's first-run setup skip its own font install.
        file.${userFontDir} = {
          source = "${radar}/share/fonts/truetype";
          recursive = true;
        };

        packages = [pkgs.herdr];
      };

      # What radar's install-font.js would write into ghostty's config.
      programs.ghostty.settings.font-codepoint-map =
        map (range: "${range}=${radar.passthru.fontFamily}") radar.passthru.codepointRanges;
    }

    # `herdr integration install claude`: the hook script plus one SessionStart
    # hook in settings.json. Claude Code writes that file itself (plugins,
    # permissions), so it stays mutable and the hook is merged in at activation
    # instead of managed as a whole.
    (lib.mkIf config.programs.claude-code.enable {
      # force: replaces a copy left by an earlier `herdr integration install`.
      home.file.${claudeHookPath} = {
        source = claudeHook;
        force = true;
      };

      home.activation.herdrClaudeHook = lib.hm.dag.entryAfter ["writeBoundary"] ''
        settings="${claudeDir}/settings.json"
        entry=${lib.escapeShellArg claudeHookEntry}
        command=${lib.escapeShellArg claudeHookCommand}
        jq=${lib.getExe pkgs.jq}
        [ -f "$settings" ] || printf '{}\n' > "$settings"
        if ! "$jq" -e --arg c "$command" \
            '[.hooks.SessionStart[]?.hooks[]? | select(.command == $c)] | length > 0' \
            "$settings" >/dev/null; then
          "$jq" --argjson e "$entry" \
            '.hooks.SessionStart = ((.hooks.SessionStart // []) + [$e])' \
            "$settings" > "$settings.herdr.tmp"
          run mv "$settings.herdr.tmp" "$settings"
        fi
      '';
    })

    # `herdr integration install opencode`: a plugin auto-loaded from plugins/
    # plus a TUI plugin registered in tui.json. herdr-opencode/tui.js is the
    # v2 (cli.json) entry; it only matters once cli.json exists.
    (lib.mkIf config.programs.opencode.enable {
      xdg.configFile = {
        "opencode/plugins/herdr-agent-state.js" = {
          source = "${integrationAssets}/opencode/herdr-agent-state.js";
          force = true;
        };
        "opencode/herdr-tui-session.js" = {
          source = "${integrationAssets}/opencode/herdr-tui-session.js";
          force = true;
        };
        "opencode/herdr-opencode/tui.js" = {
          source = "${integrationAssets}/opencode/tui.js";
          force = true;
        };
      };
      programs.opencode.tui.plugin = ["./herdr-tui-session.js"];
    })
  ];
}
