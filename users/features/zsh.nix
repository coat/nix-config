{
  config,
  lib,
  pkgs,
  ...
}: {
  programs = {
    zsh = {
      enable = true;
      autocd = true;
      enableCompletion = true;
      enableVteIntegration = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      initContent =
        lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
          # Homebrew (Apple Silicon) on PATH
          eval "$(/opt/homebrew/bin/brew shellenv)"
        ''
        + ''
          # make opening things work in a herdr pane
          if [[ -n $HERDR_ENV && -z $WAYLAND_DISPLAY ]] && command -v systemctl >/dev/null; then
            eval "$(systemctl --user show-environment 2>/dev/null \
              | grep -E '^(WAYLAND_DISPLAY|DISPLAY|XDG_CURRENT_DESKTOP|XDG_SESSION_TYPE|SWAYSOCK)=' \
              | sed 's/^/export /')"
          fi

          # foot-specific shell integration (OSC 7, OSC 0, OSC 133)
          if [[ $TERM == foot* ]]; then
              function osc7-pwd() {
                  emulate -L zsh # also sets localoptions for us
                  setopt extendedglob
                  local LC_ALL=C
                  if [[ -n $TMUX ]]; then
                      printf '\eP\e]7;file://localhost%s\a\e\\' ''${PWD//(#m)([^@-Za-z&-;_~])/%''${(l:2::0:)$(([##16]#MATCH))}}
                  else
                      printf '\e]7;file://localhost%s\e\' ''${PWD//(#m)([^@-Za-z&-;_~])/%''${(l:2::0:)$(([##16]#MATCH))}}
                  fi
              }

              function chpwd-osc7-pwd() {
                  (( ZSH_SUBSHELL )) || osc7-pwd
              }
              add-zsh-hook -Uz chpwd chpwd-osc7-pwd

              function precmd {
                  if ! builtin zle; then
                      print -n "\e]133;D\e\\"
                      osc7-pwd
                  fi
                  local title="$(print -P '%2~')"
                  print -n "\e]0;''${title}\e\\"
              }

              function preexec {
                  print -n "\e]133;C\e\\"
                  print -n "\e]0;''${1[(w)1]:t}\e\\"
              }
          fi
        '';

      defaultKeymap = "emacs";

      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/zsh_history";
      };

      shellAliases = {
        # NixOS defaults to --color=tty, which drops color when piped (ls | tail)
        ls = "ls --color=always";
        ll = "ls -l";
        nix-shell = "nix-shell --run $SHELL";
      };

      sessionVariables = {
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
      };
    };
  };
}
