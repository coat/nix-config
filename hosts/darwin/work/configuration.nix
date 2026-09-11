{
  pkgs,
  username,
  ...
}: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [colima];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "ca-derivations nix-command flakes";
  nix.settings.trusted-users = ["kent.smith"];
  # nix.settings.ssl-cert-file = "";

  nix.gc = {
    automatic = true;
    interval = {Weekday = 1;};
    options = "--delete-older-than 14d";
  };

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;
  programs.zsh.enable = true;

  # Set Git commit hash for darwin-version.
  #system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  system = {
    primaryUser = username;

    defaults = {
      dock = {
        expose-animation-duration = 0.1;
        expose-group-apps = true;
        launchanim = false;
        mru-spaces = false;
        tilesize = 32;

        persistent-apps = [
          {
            app = "/Applications/Google Chrome.app";
          }
          {
            app = "/Applications/Slack.app";
          }
        ];
      };
      menuExtraClock.ShowAMPM = false;
      menuExtraClock.ShowDate = 1;
      menuExtraClock.ShowDayOfMonth = true;
      menuExtraClock.ShowDayOfWeek = true;
      #universalaccess.reduceMotion = true;
      NSGlobalDomain = {
        "com.apple.sound.beep.volume" = 0.606531; # 50%
        "com.apple.swipescrolldirection" = false;

        ApplePressAndHoldEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        # speed up animation on open/save boxes (default:0.2)
        NSWindowResizeTime = 0.001;
        # when the below is on, it means you can hold cmd+ctrl and click anywhere on a window to drag it around
        NSWindowShouldDragOnGesture = true;
      };
      CustomUserPreferences = {
        NSGlobalDomain = {
        };
      };
      WindowManager.EnableStandardClickToShowDesktop = false;

      screencapture.location = "~/Pictures";
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.allowUnsupportedSystem = true;

  homebrew = {
    enable = true;
    brews = [
      "datadog-labs/pack/pup"
      "docker"
      "docker-compose"
      "getsentry/tools/sentry"
    ];

    casks = [
      "aptible"
      "font-iosevka"
      "ghostty"
      "nikitabobko/tap/aerospace"
    ];

    taps = [
      "datadog-labs/pack"
    ];
  };

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
    uid = 502; # default macOS uid for first user
  };
}
