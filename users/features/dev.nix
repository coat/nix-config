{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./nixvim/dev.nix
    "${inputs.hunk}/nix/home-manager.nix"
  ];
  home = {
    packages = with pkgs; [
      alejandra
      awscli2
      devenv
      duckdb
      glow
      httpie
      jq
      lazygit
      # nono
      pgcli
      ruby
      sox
      spec-kit
      ssm-session-manager-plugin
      tree-sitter
    ];
  };

  programs = {
    gh = {
      enable = true;
      settings.aliases = {
        prs = "pr list";
      };
    };

    hunk = {
      enable = true;
      enableClaudeIntegration = true;
      enableGitIntegration = true;
      settings = {
        theme = "terminal";
        agent_notes = true;
        prompt_save_view_preferences = false;
      };
    };

    claude-code = {
      enable = true;
      # ~/.claude/CLAUDE.md
      context = ''
        ## Environment
        - All my machines run NixOS. Tools that aren't installed globally are still available through Nix.
        - Never assume a tool is missing. For Python, use `nix shell nixpkgs#python3 -c python3 ...`
          or `nix run nixpkgs#python3 -- ...`. Add packages with
          `nix shell --impure --expr 'with import <nixpkgs> {}; python3.withPackages (p: [ p.requests ])'`.
        - The same applies to any other CLI tool: `nix shell nixpkgs#<pkg> -c <cmd>`.
        - `command not found` for a bare tool is expected; rerun it through `nix shell`, don't report it as missing.
        - If a `nix shell`/`nix run` command fails, the bug is in your command (quoting, heredocs, flags),
          not in tool availability. Read the error, fix the command and retry; don't switch approach
          or tell me the tool isn't installed.
        - For anything longer than a one-liner, write the script to a file in the scratchpad and run
          `nix shell nixpkgs#python3 -c python3 <file>` instead of using heredocs or nested quotes.
      '';
    };

    opencode = {
      enable = true;
      settings = {
        lsp = true;
        plugin = ["opencode-devcontainers"];
      };
    };
  };

  xdg.configFile."opencode/devcontainers/config.json".text = ''
    {
      "portRangeStart": 13000,
      "portRangeEnd": 13099
    }
  '';

  # AWS profile/region helpers and devcontainer shell, for dev machines.
  programs.zsh.initContent = ''
    # function to list all the profiles in ~/.aws/config
    function aws_profiles() {
      profiles=$(aws --no-cli-pager configure list-profiles 2> /dev/null)
      if [[ -z "$profiles" ]]; then
        echo "No AWS profiles found in '$HOME/.aws/config, check if ~/.aws/config exists and properly configured.'"
        return 1
      else
        echo $profiles
      fi
    }

    # function to set AWS profile, sso login and clear the profile
    function asp() {
      available_profiles=$(aws_profiles)
      if [[ -z "$1" ]]; then
        unset AWS_DEFAULT_PROFILE AWS_PROFILE
        echo "Zero argument provided, AWS profile cleared."
        return
      fi

      echo "$available_profiles" | grep -qw "$1"
      if [[ $? -ne 0 ]]; then
        echo "Profile '$1' not configured in '$HOME/.aws/config'.\n"
        echo "Available profiles: \n$available_profiles\n"
        return 1
      else
        export AWS_DEFAULT_PROFILE="$1" AWS_PROFILE="$1"
      fi
    }

    # function to set AWS region and clear the region
    function asr() {
      if [[ -z "$1" ]]; then
        unset AWS_DEFAULT_REGION AWS_REGION
        echo "No argument provided, cleared AWS region."
        return
      else
        export AWS_DEFAULT_REGION=$1 AWS_REGION=$1
      fi
    }

    # function to list all the profiles
    function alp() {
      aws_profiles
    }

    # function to exec into a devcontainer by branch name
    function dcsh() {
      local branch=''${1:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}
      if [[ -z "$branch" ]]; then
        echo "Usage: dcsh <branch-name>"
        return 1
      fi
      docker exec -it "''${branch}_devcontainer-app-1" bash
    }
  '';
}
