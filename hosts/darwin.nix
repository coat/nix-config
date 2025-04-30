{ pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [ colima ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

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
           };
           menuExtraClock.ShowAMPM = false;
           #universalaccess.reduceMotion = true;
           NSGlobalDomain."com.apple.sound.beep.volume" = 0.0;
         };
         keyboard = {
           enableKeyMapping = true;
           remapCapsLockToControl = true;
         };
      };

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowUnsupportedSystem = true;

      homebrew = {
        enable = true;
        brews = [
          "docker"
          "docker-compose"
        ];

        casks = [
          "firefox"
          "font-iosevka"
          "ghostty"
        ];
      };

      users.users.kent = {
        home = "/Users/kent";
        shell = pkgs.zsh;
      };
    }
