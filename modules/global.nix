{
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
      extraConfig = ''
        AcceptEnv COLORTERM
      '';
    };
  };

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    keyMap = "emacs2";
  };

  security.sudo.wheelNeedsPassword = false;
}
