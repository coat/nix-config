# Settings shared by every NixOS system here, including microvm guests.
# Host-only additions live in ./global.nix.
{
  programs.zsh.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  security.sudo.wheelNeedsPassword = false;
}
