{config, ...}: {
  programs = {
    zsh = {
      enable = true;
      autocd = true;
      enableCompletion = true;
      enableVteIntegration = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      loginExtra = ''
        if [ "$(tty)" = "/dev/tty1" ]; then
          exec sway
        fi
      '';

      initContent = ''
        #make sure brew is on the path for Apple Silicon
        if [[ $(uname -m) == 'arm64' ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        #   precmd() {
        #       print -Pn "\e]133;A\e\\"
        #   }
        #   # precmd () {print -Pn "\e]0;\a"}

        # this makes opening a terminal window in current directory work
        function osc7-pwd() {
            emulate -L zsh # also sets localoptions for us
            setopt extendedglob
            local LC_ALL=C
            printf '\e]7;file://%s%s\e\' $HOST ''${PWD//(#m)([^@-Za-z&-;_~])/%''${(l:2::0:)$(([##16]#MATCH))}}
        }

        function chpwd-osc7-pwd() {
            (( ZSH_SUBSHELL )) || osc7-pwd
        }
        add-zsh-hook -Uz chpwd chpwd-osc7-pwd

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
      '';

      defaultKeymap = "emacs";

      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/zsh_history";
      };

      shellAliases = {
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
