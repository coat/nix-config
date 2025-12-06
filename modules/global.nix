{
  imports = [
    # inputs.stylix.nixosModules.stylix
    # ../modules/stylix.nix
  ];

  programs = {
    zsh.enable = true;

    fuse.userAllowOther = true;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
      };
    };
  };

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "emacs2";
  };

  security.sudo.wheelNeedsPassword = false;
}
