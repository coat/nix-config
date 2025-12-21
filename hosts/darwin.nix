{
  pkgs,
  localstack-tap,
  ...
}: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [colima];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "ca-derivations nix-command flakes";

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;
  programs.zsh.enable = true;

  # Set Git commit hash for darwin-version.
  #system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  system = {
    defaults = {
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        expose-group-apps = true;
        expose-animation-duration = 0.1;
        launchanim = false;
        mru-spaces = false;
        tilesize = 48;
      };
      menuExtraClock.ShowAMPM = false;
      #universalaccess.reduceMotion = true;
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        # speed up animation on open/save boxes (default:0.2)
        NSWindowResizeTime = 0.001;
        # when the below is on, it means you can hold cmd+ctrl and click anywhere on a window to drag it around
        NSWindowShouldDragOnGesture = true;

        "com.apple.sound.beep.volume" = 0.606531; # 50%
      };
      CustomUserPreferences = {
        NSGlobalDomain = {
        };
        "com.amethyst.Amethyst" = {
          "focus-follows-mouse" = false;
          "enables-layout-hud" = true;
          "enables-layout-hud-on-space-change" = false;
          "smart-window-margins" = true;
          "float-small-windows" = true;
          SUEnableAutomaticChecks = false;
          SUSendProfileInfo = false;
          floating = [
            {
              id = "com.apple.systempreferences";
              "window-titles" = [];
            }
          ];
        };
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  # nixpkgs.config.allowUnfree = true;
  # nixpkgs.config.allowUnsupportedSystem = true;

  homebrew = {
    enable = true;
    brews = [
      "aichat"
      "awscli-local"
      "docker"
      "docker-compose"
      "localstack-cli"
    ];

    casks = [
      "amethyst"
      "firefox"
      "font-iosevka"
      "ghostty"
    ];

    taps = [
      "localstack/tap"
    ];
  };

  users.users.kent = {
    home = "/Users/kent";
    shell = pkgs.zsh;
  };
}
